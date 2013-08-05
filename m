Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 7B3B76B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 01:43:39 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id fn20so1726588lab.9
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 22:43:37 -0700 (PDT)
Date: Mon, 5 Aug 2013 09:43:35 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 1/2] [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130805054335.GC7999@moon>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.844299768@gmail.com>
 <51ff047d.2768310a.2fc4.340fSMTPIN_ADDED_BROKEN@mx.google.com>
 <20130805021715.GJ32486@bbox>
 <51ff1053.ab47310a.5d3f.566cSMTPIN_ADDED_BROKEN@mx.google.com>
 <20130805025437.GK32486@bbox>
 <51ff14e9.87ef440a.1424.ffffe470SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ff14e9.87ef440a.1424.ffffe470SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, xemul@parallels.com, akpm@linux-foundation.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Mon, Aug 05, 2013 at 10:58:35AM +0800, Wanpeng Li wrote:
> >
> >pte_to_swp_entry is passed orig_pte by vaule, not a pointer
> >so although pte_to_swp_entry clear out _PTE_SWP_SOFT_DIRTY, it does it in local-copy.
> >So orig_pte is never changed.
> 
> Ouch! Thanks for pointing out. ;-)
> 
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Yeah, it's a bit tricky. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
