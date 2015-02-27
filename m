Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 156306B006C
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 07:43:24 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id bm13so12486536qab.2
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 04:43:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i4si3904179qcz.48.2015.02.27.04.43.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 04:43:22 -0800 (PST)
Message-ID: <54F06636.6080905@redhat.com>
Date: Fri, 27 Feb 2015 07:42:30 -0500
From: Jon Masters <jcm@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4 0/6] RCU get_user_pages_fast and __get_user_pages_fast
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, hughd@google.com

On 09/26/2014 10:03 AM, Steve Capper wrote:

> This series implements general forms of get_user_pages_fast and
> __get_user_pages_fast in core code and activates them for arm and arm64.
> 
> These are required for Transparent HugePages to function correctly, as
> a futex on a THP tail will otherwise result in an infinite loop (due to
> the core implementation of __get_user_pages_fast always returning 0).
> 
> Unfortunately, a futex on THP tail can be quite common for certain
> workloads; thus THP is unreliable without a __get_user_pages_fast
> implementation.
> 
> This series may also be beneficial for direct-IO heavy workloads and
> certain KVM workloads.
> 
> I appreciate that the merge window is coming very soon, and am posting
> this revision on the off-chance that it gets the nod for 3.18. (The changes
> thus far have been minimal and the feedback I've got has been mainly
> positive).

Head's up: these patches are currently implicated in a rare-to-trigger
hang that we are seeing on an internal kernel. An extensive effort is
underway to confirm whether these are the cause. Will followup.

Jon.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
