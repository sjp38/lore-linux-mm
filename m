Date: Tue, 11 Nov 2008 15:26:57 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
In-Reply-To: <20081111210655.GG10818@random.random>
Message-ID: <Pine.LNX.4.64.0811111522150.27767@quilx.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
 <1226409701-14831-2-git-send-email-ieidus@redhat.com>
 <1226409701-14831-3-git-send-email-ieidus@redhat.com>
 <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008, Andrea Arcangeli wrote:

> btw, page_migration likely is buggy w.r.t. o_direct too (and now
> unfixable with gup_fast until the 2.4 brlock is added around it or
> similar) if it does the same thing but without any page_mapcount vs
> page_count check.

Details please?

> page_migration does too much for us, so us calling into migrate.c may
> not be ideal. It has to convert a fresh page to a VM page. In KSM we
> don't convert the newpage to be a VM page, we just replace the anon
> page with another page. The new page in the KSM case is not a page
> known by the VM, not in the lru etc...

A VM page as opposed to pages not in the VM? ???

page migration requires the page to be on the LRU. That could be changed
if you have a different means of isolating a page from its page tables.

> The way to go could be to change the page_migration to use
> replace_page (or __replace_page if called in some shared inner-lock
> context) after preparing the newpage to be a regular VM page. If we
> can do that, migrate.c will get the o_direct race fixed too for free.

Define a regular VM page? A page on the LRU?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
