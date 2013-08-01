Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id E3C136B0037
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 02:36:40 -0400 (EDT)
Date: Thu, 1 Aug 2013 15:37:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch 1/2] [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130801063706.GF19540@bbox>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.844299768@gmail.com>
 <20130801005132.GB19540@bbox>
 <20130801055303.GA1764@moon>
 <20130801061632.GE19540@bbox>
 <20130801062814.GB1764@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130801062814.GB1764@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, xemul@parallels.com, akpm@linux-foundation.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Thu, Aug 01, 2013 at 10:28:14AM +0400, Cyrill Gorcunov wrote:
> On Thu, Aug 01, 2013 at 03:16:32PM +0900, Minchan Kim wrote:
> > 
> > I don't get it. Could you correct me with below example?
> > 
> > Process A context
> >         try_to_unmap
> >                 swp_pte = swp_entry_to_pte /* change generic swp into arch swap */
> >                 swp_pte = pte_swp_mksoft_dirty(swp_pte);
> >                 set_pte_at(, swp_pte);
> > 
> > Process A context
> >         ..
> >         mincore_pte_range
> 		pte_t pte = *ptep;	<-- local copy of the pte value, in memory it remains the same
> 						with swap softdirty bit set

Argh, I missed that. Thank you!

Reviewed-by: Minchan Kim <minchan@kernel.org>
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
