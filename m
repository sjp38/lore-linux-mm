Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id 091BE6B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 23:59:09 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id j17so1333741oag.14
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 20:59:09 -0700 (PDT)
Received: from mail-oa0-x233.google.com (mail-oa0-x233.google.com [2607:f8b0:4003:c02::233])
        by mx.google.com with ESMTPS id b5si17913380obq.212.2014.04.29.20.59.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 20:59:09 -0700 (PDT)
Received: by mail-oa0-f51.google.com with SMTP id l6so1321501oag.38
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 20:59:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG4AFWaemUiR1HTx5dUUQf3V4twuwuiBdtDLNEeEoF-ikTThpQ@mail.gmail.com>
References: <CAG4AFWaemUiR1HTx5dUUQf3V4twuwuiBdtDLNEeEoF-ikTThpQ@mail.gmail.com>
Date: Tue, 29 Apr 2014 23:59:09 -0400
Message-ID: <CAG4AFWa0MGEZvyqq5VWCpsQGFCGbu-16V_djv_sEW6YV3VDSGw@mail.gmail.com>
Subject: Re: Is heap_stack_gap useless?
From: Jidong Xiao <jidong.xiao@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kernel development list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Resend to kernel-development list.

The original email wasn't plaintext mode and was rejected by
kernel-development list.

On Tue, Apr 29, 2014 at 11:31 PM, Jidong Xiao <jidong.xiao@gmail.com> wrote:
> Hi,
>
> I noticed this variable, defined in mm/nommu.c,
>
> mm/nommu.c:int heap_stack_gap = 0;
>
> This variable only shows up once, and never shows up in elsewhere.
>
> Can some one tell me is this useless? If so, I will submit a patch to remove
> it.
>
> -Jidong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
