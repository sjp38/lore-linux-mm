Date: Fri, 9 May 2003 19:40:12 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.69-mm3
Message-ID: <20030509141012.GD2059@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20030508013958.157b27b7.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030508013958.157b27b7.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2003 at 08:41:12AM +0000, Andrew Morton wrote:
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.69-mm3.gz
> 
>   Will appear sometime at
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm3/
> 
> 
> Small things.  Mainly a resync for various people...
> 
> rcu-stats.patch
>   RCU statistics reporting

I am wondering what we should do with this patch. The RCU stats display
the #s of RCU requests and actual updates on each CPU. On a normal system
they don't mean much to a sysadmin, so I am not sure if it is the right
thing to include this feature. OTOH, it is extremely useful to detect
potential memory leaks happening due to, say a CPU looping in
kernel (and RCU not happening consequently). Will a CONFIG_RCU_DEBUG
make it more palatable for mainline ?

Thanks
Dipankar
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
