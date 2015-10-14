Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3C36B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 14:40:54 -0400 (EDT)
Received: by igbif5 with SMTP id if5so27400142igb.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 11:40:54 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id z18si18212407igr.26.2015.10.14.11.40.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 11:40:53 -0700 (PDT)
Received: by iofl186 with SMTP id l186so65444334iof.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 11:40:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1510141301340.13301@east.gentwo.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
	<CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
	<alpine.DEB.2.20.1510141301340.13301@east.gentwo.org>
Date: Wed, 14 Oct 2015 11:40:53 -0700
Message-ID: <CA+55aFwSjroKXPjsO90DWULy-H8e9Fs=ZDRVkJvQgAZPk1YYRw@mail.gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 14, 2015 at 11:03 AM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 14 Oct 2015, Linus Torvalds wrote:
>>
>> So why is this a bugfix? If cpu == WORK_CPU_UNBOUND, then things
>> _shouldn't_ care which cpu it gets run on.
>
> UNBOUND means not fixed to a processor.

That's exactly what I'm saying.

And "schedule_delayed_work()" uses WORK_CPU_UNBOUND.

YOUR code assumes that means "local CPU".

And I say that's bogus.

In this email you seem to even agree that its' bogus, but then you
wrote another email saying that the code isn't confused, because it
uses "schedule_delayed_work()" on the CPU that it wants to run the
code on.

I'm saying that mm/vmstat.c should use "schedule_delayed_work_on()".

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
