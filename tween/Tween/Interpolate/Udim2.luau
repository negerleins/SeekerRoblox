return function(alpha: number, initial: UDim2, final: UDim2)
	return initial:Lerp(final, alpha)
end
