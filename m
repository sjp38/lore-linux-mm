Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 470006B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 05:09:53 -0500 (EST)
Received: by faas10 with SMTP id s10so1744267faa.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 02:09:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EC264AA.30306@redhat.com>
References: <4EB3FA89.6090601@redhat.com>
	<4EC264AA.30306@redhat.com>
Date: Wed, 16 Nov 2011 15:39:39 +0530
Message-ID: <CAKTCnzkczaSo==AJREX1LtbBeeybn3fsKS84ibbgc_FEMbedFg@mail.gmail.com>
Subject: Re: [RFC PATCH V2] Enforce RSS+Swap rlimit
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Nov 15, 2011 at 6:40 PM, Jerome Marchand <jmarchan@redhat.com> wrote:
>
> Change since V1: rebase on 3.2-rc1
>
> Currently RSS rlimit is not enforced. We can not forbid a process to exceeds
> its RSS limit and allow it swap out. That would hurts the performance of all
> system, even when memory resources are plentiful.
>
> Therefore, instead of enforcing a limit on rss usage alone, this patch enforces
> a limit on rss+swap value. This is similar to memsw limits of cgroup.
> If a process rss+swap usage exceeds RLIMIT_RSS max limit, he received a SIGBUS
> signal.
>
> My tests show that code in do_anonymous_page() and __do_fault() indeed prevents
> processes to get more memory than the limit and I haven't seen any adverse
> effect, but so far, I have no test coverage of the code in do_wp_page(). I'm
> not sure how to test it.
>
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

I think we need the get_mm_rss* definitions need to be revisited and
agreed upon. I am afraid it cannot be simple addition, since

1. It does not account for shared pages
2. If we enforce a limit without accounting for sharing, we might
enforce wrong limits

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
