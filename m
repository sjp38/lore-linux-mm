Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 482F98D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 08:31:37 -0400 (EDT)
Message-ID: <4CCABEA0.8080909@redhat.com>
Date: Fri, 29 Oct 2010 08:31:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
References: <1288200090-23554-1-git-send-email-yinghan@google.com>	<4CC869F5.2070405@redhat.com>	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>	<AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>	<alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>	<AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>	<20101028091158.4de545e9.kamezawa.hiroyu@jp.fujitsu.com>	<AANLkTikdE---MJ-LSwNHEniCphvwu0T2apkWzGsRQ8i=@mail.gmail.com>	<20101029114529.4d3a8b9c.kamezawa.hiroyu@jp.fujitsu.com>	<4CCA42D0.5090603@redhat.com> <AANLkTiku321ZpSrO4hSLyj7n9NM7QvN+RQ-A73KK4eRa@mail.gmail.com>
In-Reply-To: <AANLkTiku321ZpSrO4hSLyj7n9NM7QvN+RQ-A73KK4eRa@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ken Chen <kenchen@google.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 10/29/2010 12:27 AM, Minchan Kim wrote:

> What happens if we don't flush TLB?
> It will make for old page to pretend young page.
> If it is, how does it affect reclaim?

Other way around - it will make a young page pretend to be an
old page, because the TLB won't know it needs to flush the
Accessed bit into the page tables (where the bit was recently
cleared).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
