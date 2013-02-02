Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DE9216B0007
	for <linux-mm@kvack.org>; Sat,  2 Feb 2013 07:59:54 -0500 (EST)
Date: Sat, 2 Feb 2013 20:59:52 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [slab:slab/next 11/13] mm/slab_common.c:385:13: sparse:
 restricted gfp_t degrades to integer
Message-ID: <20130202125952.GE16114@localhost>
References: <510bae53.+nWBFPQ3bGiTzPs/%fengguang.wu@intel.com>
 <0000013c971ab472-8542127a-19e8-4f6a-8b7e-5f5ab8bcd8fd-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013c971ab472-8542127a-19e8-4f6a-8b7e-5f5ab8bcd8fd-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Feb 01, 2013 at 06:52:55PM +0000, Christoph Lameter wrote:
> On Fri, 1 Feb 2013, kbuild test robot wrote:
> 
> >    374		int index;
> >    375
> >    376		if (size <= 192) {
> >    377			if (!size)
> >    378				return ZERO_SIZE_PTR;
> >    379
> >    380			index = size_index[size_index_elem(size)];
> >    381		} else
> >    382			index = fls(size - 1);
> >    383
> >    384	#ifdef CONFIG_ZONE_DMA
> >  > 385		if (unlikely((flags & SLAB_CACHE_DMA)))
> 
> Should flags be cast to integer before doing the & operation?

It seems not easy to quiet this warning..

(unsigned long)flags & SLAB_CACHE_DMA
/c/wfg/sound/mm/slab_common.c:385:13: sparse: cast from restricted gfp_t

flags & (gfp_t)SLAB_CACHE_DMA
/c/wfg/sound/mm/slab_common.c:385:13: sparse: cast to restricted gfp_t

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
