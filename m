Date: Wed, 23 Jan 2008 12:05:10 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [kvm-devel] [RFC][PATCH 0/5] Memory merging driver for Linux
Message-ID: <20080123120510.4014e382@bree.surriel.com>
In-Reply-To: <4794C2E1.8040607@qumranet.com>
References: <4794C2E1.8040607@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jan 2008 18:05:53 +0200
Izik Eidus <izike@qumranet.com> wrote:

> i added 2 new functions to the kernel
> one:
> page_wrprotect() make the page as read only by setting the ptes point to
> it as read only.
> second:
> replace_page() - replace the pte mapping related to vm area between two 
> pages

How will this work on CPUs with nested paging support, where the
CPU does the guest -> physical address translation?  (opposed to
having shadow page tables)

Is it sufficient to mark the page read-only in the guest->physical
translation page table?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
