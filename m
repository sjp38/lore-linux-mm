Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B95B6B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 07:37:37 -0500 (EST)
Received: by iwn5 with SMTP id 5so3072563iwn.11
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 04:37:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091101073527.GB32720@elf.ucw.cz>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie>
	 <20091027130924.fa903f5a.akpm@linux-foundation.org>
	 <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com>
	 <20091031184054.GB1475@ucw.cz>
	 <alpine.DEB.2.00.0910311248490.13829@chino.kir.corp.google.com>
	 <20091031201158.GB29536@elf.ucw.cz>
	 <alpine.DEB.2.00.0910311413160.25524@chino.kir.corp.google.com>
	 <20091031222905.GA32720@elf.ucw.cz> <4AECC04B.9060808@redhat.com>
	 <20091101073527.GB32720@elf.ucw.cz>
Date: Sun, 1 Nov 2009 21:37:35 +0900
Message-ID: <2f11576a0911010437l45b64f64webffa649763406b1@mail.gmail.com>
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use
	ALLOC_HARDER
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2009/11/1 Pavel Machek <pavel@ucw.cz>:
>> > I believe it would be better to simply remove it.
>>
>> You are against trying to give the realtime tasks a best effort
>> advantage at memory allocation?
>
> Yes. Those memory reserves were for kernel, GPF_ATOMIC and stuff. Now
> realtime tasks are allowed to eat into them. That feels wrong.
>
> "realtime" tasks are not automatically "more important".
>
>> Realtime apps often *have* to allocate memory on the kernel side,
>> because they use network system calls, etc...
>
> So what? As soon as they do that, they lose any guarantees, anyway.

Then, your proposal makes regression to rt workload. any improve idea
is welcome.
but we don't hope to see any regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
