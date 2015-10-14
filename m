Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id EE34B6B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 14:59:34 -0400 (EDT)
Received: by ioii196 with SMTP id i196so65575941ioi.3
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 11:59:34 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id sa1si8527264igb.17.2015.10.14.11.59.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 11:59:34 -0700 (PDT)
Date: Wed, 14 Oct 2015 13:59:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
In-Reply-To: <CA+55aFwSjroKXPjsO90DWULy-H8e9Fs=ZDRVkJvQgAZPk1YYRw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1510141358460.13663@east.gentwo.org>
References: <20151013214952.GB23106@mtj.duckdns.org> <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com> <alpine.DEB.2.20.1510141301340.13301@east.gentwo.org> <CA+55aFwSjroKXPjsO90DWULy-H8e9Fs=ZDRVkJvQgAZPk1YYRw@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, 14 Oct 2015, Linus Torvalds wrote:

> And "schedule_delayed_work()" uses WORK_CPU_UNBOUND.

Uhhh. Someone changed that?

> In this email you seem to even agree that its' bogus, but then you
> wrote another email saying that the code isn't confused, because it
> uses "schedule_delayed_work()" on the CPU that it wants to run the
> code on.
>
> I'm saying that mm/vmstat.c should use "schedule_delayed_work_on()".

Then that needs to be fixed. Could occur in more places.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
