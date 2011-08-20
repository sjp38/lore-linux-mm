Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0C56B0169
	for <linux-mm@kvack.org>; Sat, 20 Aug 2011 14:45:31 -0400 (EDT)
Received: by eyh6 with SMTP id 6so2492756eyh.20
        for <linux-mm@kvack.org>; Sat, 20 Aug 2011 11:45:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110820132701.GA29322@redhat.com>
References: <CAOn_VZYLOG9ctDomhMzyk19jVeKWWMvftvjyXRwfCyNn+4jinA@mail.gmail.com>
	<20110820132701.GA29322@redhat.com>
Date: Sun, 21 Aug 2011 00:15:28 +0530
Message-ID: <CAOn_VZb5XqgvTweRY3unTLvrOE4DFMfJK5TDc3TeGk7ordPeUA@mail.gmail.com>
Subject: Re: what protects page lru list?
From: Rajesh Ghanekar <rajeshsg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org

Thanks Johannes. It makes sense. I was searching for any code in
which pages is on free list and being operated with lru_lock. But as
you said only pages on LRU lists are operated by lru_lock.

I am facing a panic in __rmqueue at list_del where the struct page
is corrupted or probably the free_list is corrupted. The kernel is
2.6.32.43.xxx from SLES11SP1. I will first see if any of the other code
(proprietary) running is not broken.

- Rajesh

On Sat, Aug 20, 2011 at 6:57 PM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> On Sat, Aug 20, 2011 at 02:11:53AM +0530, Rajesh Ghanekar wrote:
>> Hi,
>> =A0 =A0I am confused with what protects page->lru? Is it both zone->lru_=
lock or
>> zone->lock? I can see it being protected either by lru_lock or lock.
>
> It's not so much about page->lru but the actual list the page is
> linked to.
>
> The zone's lists of unallocated pages are protected by zone->lock,
> while the LRU lists with the pages for userspace are protected by
> zone->lru_lock.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
