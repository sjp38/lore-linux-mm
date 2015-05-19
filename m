Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 685C26B0085
	for <linux-mm@kvack.org>; Tue, 19 May 2015 01:20:40 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so4095419wgb.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 22:20:39 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id v8si16298082wiz.39.2015.05.18.22.20.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 22:20:38 -0700 (PDT)
Received: by wicmc15 with SMTP id mc15so103896766wic.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 22:20:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150518152723.769799cced031e71582bfa74@linux-foundation.org>
References: <1431974526-21788-1-git-send-email-leon@leon.nu> <20150518152723.769799cced031e71582bfa74@linux-foundation.org>
From: Leon Romanovsky <leon@leon.nu>
Date: Tue, 19 May 2015 08:20:12 +0300
Message-ID: <CALq1K=+Yb11MtNz7sszSLKu0+c8tOGEW8cihsP6t1bFU5JiTbA@mail.gmail.com>
Subject: Re: [PATCH] mm: nommu: convert kenter/kleave/kdebug macros to use pr_devel()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dhowells <dhowells@redhat.com>, aarcange <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, May 19, 2015 at 1:27 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 18 May 2015 21:42:06 +0300 Leon Romanovsky <leon@leon.nu> wrote:
>
>> kenter/kleave/kdebug are wrapper macros to print functions flow and debug
>> information. This set was written before pr_devel() was introduced, so
>> it was controlled by "#if 0" construction.
>>
>> This patch refactors the current macros to use general pr_devel()
>> functions which won't be compiled in if "#define DEBUG" is not declared
>> prior to that macros.
>
> I doubt if anyone has used these in a decade and only a tenth of the
> mm/nommu.c code is actually wired up to use the macros.

A couple of days before, the question "how to handle such code" [1]
was raised by me. Later, Joe Perches suggested to add into
consideration the "delete option" [2].

> I'd suggest just removing it all.  If someone later has a need, they
> can add their own pr_devel() calls.
My patch followed the preference of initial author (David Howells [3] and [4]).

Please advise how should I proceed with it.

[1] [RFC] Refactor kenter/kleave/kdebug macros -
https://lkml.org/lkml/2015/5/16/279
[2] https://lkml.org/lkml/2015/5/16/280
[3] https://lkml.org/lkml/2015/5/18/199
[4] https://lkml.org/lkml/2015/5/18/457

Thanks.


-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
