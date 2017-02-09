Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A504428089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 23:50:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so220486340pfb.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 20:50:34 -0800 (PST)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id v18si9010726pge.225.2017.02.08.20.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 20:50:33 -0800 (PST)
Received: by mail-pg0-x22d.google.com with SMTP id 194so54290393pgd.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 20:50:33 -0800 (PST)
Date: Wed, 8 Feb 2017 20:50:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix KPF_SWAPCACHE
In-Reply-To: <20170209142026.6861ffb0@roar.ozlabs.ibm.com>
Message-ID: <alpine.LSU.2.11.1702082045430.1818@eggly.anvils>
References: <alpine.LSU.2.11.1702071105360.11828@eggly.anvils> <20170209142026.6861ffb0@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 9 Feb 2017, Nicholas Piggin wrote:
> On Tue, 7 Feb 2017 11:11:16 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > 4.10-rc1 commit 6326fec1122c ("mm: Use owner_priv bit for PageSwapCache,
> > valid when PageSwapBacked") aliased PG_swapcache to PG_owner_priv_1:
> > so /proc/kpageflags' KPF_SWAPCACHE should now be synthesized, instead
> > of being shown on unrelated pages which have PG_owner_priv_1 set.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> Thanks Hugh, this seems fine to me. We want this for 4.10, no?
> 
> Fixes: 6326fec1122c ("mm: Use owner_priv bit for PageSwapCache, valid when PageSwapBacked")
> Reviewed-by: Nicholas Piggin <npiggin@gmail.com>

Thanks Nick, yes, but don't worry: Linus jumped to it, and it's already
in 4.10 as b6789123bccb ("mm: fix KPF_SWAPCACHE in /proc/kpageflags").

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
