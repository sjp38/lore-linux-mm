Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69BFF440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:46:28 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w126so843412oig.4
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:46:28 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id c10si3420356oia.341.2017.08.24.06.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 06:46:27 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id c129so2417803oif.2
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:46:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170824132801.GM11771@tardis>
References: <20170823152542.5150-1-boqun.feng@gmail.com> <20170823152542.5150-2-boqun.feng@gmail.com>
 <alpine.DEB.2.20.1708241507160.1860@nanos> <20170824132801.GM11771@tardis>
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 24 Aug 2017 15:46:26 +0200
Message-ID: <CAK8P3a1bVCxJCi_84abo4Bk7LFr7ynO1=7bW5dm=jbLvH9sR2Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] nfit: Use init_completion() in acpi_nfit_flush_probe()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Byungchul Park <byungchul.park@lge.com>, Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, Nicholas Piggin <npiggin@gmail.com>, kernel-team@lge.com, Dan Williams <dan.j.williams@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-nvdimm@lists.01.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Thu, Aug 24, 2017 at 3:28 PM, Boqun Feng <boqun.feng@gmail.com> wrote:
> On Thu, Aug 24, 2017 at 03:07:42PM +0200, Thomas Gleixner wrote:
>> On Wed, 23 Aug 2017, Boqun Feng wrote:
>>
>> > There is no need to use COMPLETION_INITIALIZER_ONSTACK() in
>> > acpi_nfit_flush_probe(), replace it with init_completion().
>>
>> You completely fail to explain WHY.
>>
>
> I thought COMPLETION_INITIALIZER_ONSTACK() should only use in assigment
> or compound literals, so the usage here is obviously wrong, but seems
> I was wrong?
>
> Ingo,
>
> Is the usage of COMPLETION_INITIALIZER_ONSTACK() correct? If not,
> I could rephrase my commit log saying this is a fix for wrong usage of
> COMPLETION_INITIALIZER_ONSTACK(), otherwise, I will rewrite the commit
> indicating this patch is a necessary dependency for patch #2. Thanks!

I think your patch is correct, but your changelog text is useless, as
Thomas mentioned: you should instead explain that it breaks with the
other fix in the series, and what the difference between init_completion()
and COMPLETION_INITIALIZER_ONSTACK() is.

      Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
