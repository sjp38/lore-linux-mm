Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 191CF6B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 15:10:53 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so38204pbb.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 12:10:52 -0700 (PDT)
Date: Tue, 15 May 2012 12:10:47 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] slub: fix a memory leak in get_partial_node()
Message-ID: <20120515191047.GA22765@kroah.com>
References: <1337108498-4104-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337108498-4104-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, May 16, 2012 at 04:01:38AM +0900, Joonsoo Kim wrote:
> In the case which is below,
> 
> 1. acquire slab for cpu partial list
> 2. free object to it by remote cpu
> 3. page->freelist = t
> 
> then memory leak is occurred.
> 
> Change acquire_slab() not to zap freelist when it works for cpu partial list.
> I think it is a sufficient solution for fixing a memory leak.
> 
> Below is output of 'slabinfo -r kmalloc-256'
> when './perf stat -r 30 hackbench 50 process 4000 > /dev/null' is done.
> 
> ***Vanilla***
> Sizes (bytes)     Slabs              Debug                Memory
> ------------------------------------------------------------------------
> Object :     256  Total  :     468   Sanity Checks : Off  Total: 3833856
> SlabObj:     256  Full   :     111   Redzoning     : Off  Used : 2004992
> SlabSiz:    8192  Partial:     302   Poisoning     : Off  Loss : 1828864
> Loss   :       0  CpuSlab:      55   Tracking      : Off  Lalig:       0
> Align  :       8  Objects:      32   Tracing       : Off  Lpadd:       0
> 
> ***Patched***
> Sizes (bytes)     Slabs              Debug                Memory
> ------------------------------------------------------------------------
> Object :     256  Total  :     300   Sanity Checks : Off  Total: 2457600
> SlabObj:     256  Full   :     204   Redzoning     : Off  Used : 2348800
> SlabSiz:    8192  Partial:      33   Poisoning     : Off  Loss :  108800
> Loss   :       0  CpuSlab:      63   Tracking      : Off  Lalig:       0
> Align  :       8  Objects:      32   Tracing       : Off  Lpadd:       0
> 
> Total and loss number is the impact of this patch.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
