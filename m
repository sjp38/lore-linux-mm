Message-ID: <47B335A6.3080806@oracle.com>
Date: Wed, 13 Feb 2008 10:23:34 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
References: <20080211224105.GB24412@linux.intel.com> <20080211152716.65f5a753.randy.dunlap@oracle.com> <20080212160553.GD27490@linux.intel.com> <47B1CA9F.80004@oracle.com> <20080212195532.GA29132@linux.intel.com> <47B1FFB4.7010904@oracle.com> <20080213181029.GA1162@linux.intel.com>
In-Reply-To: <20080213181029.GA1162@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Index: linux-2.6.24-mm1/Documentation/kernel-parameters.txt
> ===================================================================
> --- linux-2.6.24-mm1.orig/Documentation/kernel-parameters.txt	2008-02-12 07:12:06.000000000 -0800
> +++ linux-2.6.24-mm1/Documentation/kernel-parameters.txt	2008-02-12 11:36:07.000000000 -0800
> @@ -822,6 +822,10 @@
>  			than 32 bit addressing. The default is to look
>  			for translation below 32 bit and if not available
>  			then look in the higher range.
> +		strict [Default Off]
> +			With this option on every umap_single operation will

so I'll ask one more time :(
Shouldn't this be "unmap_single" ?

> +			result in a hardware IOTLB flush operation as opposed
> +			to batching them for performance.
>  
>  	io_delay=	[X86-32,X86-64] I/O delay method
>  		0x80


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
