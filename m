Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 96BD46B00FD
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 21:30:40 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o9T1UROd025974
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:30:29 -0700
Received: from iwn39 (iwn39.prod.google.com [10.241.68.103])
	by wpaz9.hot.corp.google.com with ESMTP id o9T1UNiY019437
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:30:26 -0700
Received: by iwn39 with SMTP id 39so3030605iwn.27
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:30:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101028091158.4de545e9.kamezawa.hiroyu@jp.fujitsu.com>
References: <1288200090-23554-1-git-send-email-yinghan@google.com>
	<4CC869F5.2070405@redhat.com>
	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>
	<AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>
	<alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>
	<AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>
	<20101028091158.4de545e9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Oct 2010 18:30:23 -0700
Message-ID: <AANLkTikdE---MJ-LSwNHEniCphvwu0T2apkWzGsRQ8i=@mail.gmail.com>
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
From: Ken Chen <kenchen@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2010 at 5:11 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I'd like to vote for batching.

Batch mode isn't going to add much value because the effect of
accessed bit is already deferred.  There are two outcome: (1) the tlb
mapping is already flushed due to capacity conflict or (2) process
context'ed out.  You would want to transfer accessed bit from pte to
page table, but flushing TLB on a already deferred operation seems not
that useful.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
