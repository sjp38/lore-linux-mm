Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 881846B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 17:12:48 -0500 (EST)
Received: by qafl39 with SMTP id l39so1706782qaf.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 14:12:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.02.1202281043420.4106@tux.localdomain>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<alpine.LFD.2.02.1202281043420.4106@tux.localdomain>
Date: Tue, 28 Feb 2012 14:12:47 -0800
Message-ID: <CABCjUKA10uYsTm9KBUObXK92nM0HSrPZt591Bt5t+jst8BBdPQ@mail.gmail.com>
Subject: Re: [PATCH 00/10] memcg: Kernel Memory Accounting.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org, rientjes@google.com, cl@linux-foundation.org, akpm@linux-foundation.org

Hello,

On Tue, Feb 28, 2012 at 12:49 AM, Pekka Enberg <penberg@kernel.org> wrote:
> On Mon, 27 Feb 2012, Suleiman Souhlal wrote:
>> The main difference with Glauber's patches is here: We try to
>> track all the slab allocations, while Glauber only tracks ones
>> that are explicitly marked.
>> We feel that it's important to track everything, because there
>> are a lot of different slab allocations that may use significant
>> amounts of memory, that we may not know of ahead of time.
>> This is also the main source of complexity in the patchset.
>
> Well, what are the performance implications of your patches? Can we
> reasonably expect distributions to be able to enable this thing on
> generic kernels and leave the feature disabled by default? Can we
> accommodate your patches to support Glauber's use case?

I don't have up to date performance numbers, but we haven't found any
critical performance degradations on our workloads, with our internal
versions of this patchset.

There are some conditional branches added to the slab fast paths, but
I think it should be possible to come with a way to get rid of those
when the feature is disabled, maybe by using  a static_branch. This
should hopefully make it possible to keep the feature compiled in but
disabled at runtime.

I think it's definitely possible to accommodate my patches to support
Glauber's use case, with a bit of work.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
