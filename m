Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 28BC96B0169
	for <linux-mm@kvack.org>; Sat, 20 Aug 2011 09:27:07 -0400 (EDT)
Date: Sat, 20 Aug 2011 15:27:01 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: what protects page lru list?
Message-ID: <20110820132701.GA29322@redhat.com>
References: <CAOn_VZYLOG9ctDomhMzyk19jVeKWWMvftvjyXRwfCyNn+4jinA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOn_VZYLOG9ctDomhMzyk19jVeKWWMvftvjyXRwfCyNn+4jinA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rajesh Ghanekar <rajeshsg@gmail.com>
Cc: linux-mm@kvack.org

On Sat, Aug 20, 2011 at 02:11:53AM +0530, Rajesh Ghanekar wrote:
> Hi,
>    I am confused with what protects page->lru? Is it both zone->lru_lock or
> zone->lock? I can see it being protected either by lru_lock or lock.

It's not so much about page->lru but the actual list the page is
linked to.

The zone's lists of unallocated pages are protected by zone->lock,
while the LRU lists with the pages for userspace are protected by
zone->lru_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
