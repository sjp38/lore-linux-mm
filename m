Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A9E735F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 18:14:49 -0400 (EDT)
Date: Tue, 14 Apr 2009 15:09:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] add replace_page(): change the page pte is pointing
 to.
Message-Id: <20090414150925.58b464f7.akpm@linux-foundation.org>
In-Reply-To: <1239249521-5013-4-git-send-email-ieidus@redhat.com>
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com>
	<1239249521-5013-2-git-send-email-ieidus@redhat.com>
	<1239249521-5013-3-git-send-email-ieidus@redhat.com>
	<1239249521-5013-4-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu,  9 Apr 2009 06:58:40 +0300
Izik Eidus <ieidus@redhat.com> wrote:

> replace_page() allow changing the mapping of pte from one physical page
> into diffrent physical page.

At a high level, this is very similar to what page migration does.  Yet
this implementation shares nothing with the page migration code.

Can this situation be improved?

> this function is working by removing oldpage from the rmap and calling
> put_page on it, and by setting the pte to point into newpage and by
> inserting it to the rmap using page_add_file_rmap().
> 
> note: newpage must be non anonymous page, the reason for this is:
> replace_page() is built to allow mapping one page into more than one
> virtual addresses, the mapping of this page can happen in diffrent
> offsets inside each vma, and therefore we cannot trust the page->index
> anymore.
> 
> the side effect of this issue is that newpage cannot be anything but
> kernel allocated page that is not swappable.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
