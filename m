Date: Thu, 22 Aug 2002 20:24:12 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Lse-tech] [patch] Simple Topology API v0.3 (2/2)
Message-ID: <20020822202412.B30036@infradead.org>
References: <3D65383B.9030406@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D65383B.9030406@us.ibm.com>; from colpatch@us.ibm.com on Thu, Aug 22, 2002 at 12:15:07PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2002 at 12:15:07PM -0700, Matthew Dobson wrote:
> diff -Nur linux-2.5.27-vanilla/kernel/sys.c linux-2.5.27-api/kernel/sys.c
> --- linux-2.5.27-vanilla/kernel/sys.c	Sat Jul 20 12:11:07 2002
> +++ linux-2.5.27-api/kernel/sys.c	Wed Jul 24 17:33:41 2002
> @@ -20,6 +20,7 @@
>  #include <linux/device.h>
>  #include <linux/times.h>
>  #include <linux/security.h>
> +#include <linux/topology.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/io.h>
> @@ -1236,6 +1237,31 @@
>  	mask = xchg(&current->fs->umask, mask & S_IRWXUGO);
>  	return mask;
>  }
> +
> +asmlinkage long sys_check_topology(int convert_type, int to_convert)
> +{
> +	int ret = 0;
> +
> +	switch (convert_type) {
> +		case CPU_TO_NODE:
> +			ret = cpu_to_node(to_convert);
> +			break;
> +		case MEMBLK_TO_NODE:
> +			ret = memblk_to_node(to_convert);
> +			break;
> +		case NODE_TO_NODE:
> +			ret = node_to_node(to_convert);
> +			break;
> +		case NODE_TO_CPU:
> +			ret = node_to_cpu(to_convert);
> +			break;
> +		case NODE_TO_MEMBLK:
> +			ret = node_to_memblk(to_convert);
> +			break;
> +	}
> +
> +	return (long)ret;
> +}

You don't consider this a proper syscall API, do you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
