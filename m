From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH 4/5] x86: Add config variables for SMP_MAX
Date: Fri, 18 Jan 2008 21:04:21 +0100
References: <20080118183011.354965000@sgi.com> <20080118183011.917801000@sgi.com>
In-Reply-To: <20080118183011.917801000@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801182104.22486.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On Friday 18 January 2008, travis@sgi.com wrote:
> +config THREAD_ORDER
> +	int "Kernel stack size (in page order)"
> +	range 1 3
> +	depends on X86_64_SMP
> +	default "3" if X86_SMP_MAX
> +	default "1"
> +	help
> +	  Increases kernel stack size.
> +

Could you please elaborate, why this is needed and put more info about
this requirement into this patch description?

People worked hard to push data allocation from stack to heap to make 
THREAD_ORDER of 0 and 1 possible. So why increase it again and why does this
help scalability?

Many thanks and Best Regards

Ingo Oeser, puzzled a bit :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
