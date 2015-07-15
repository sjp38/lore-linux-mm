Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 745842802BB
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:18:58 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so307660igb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:18:58 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id j9si5741ige.71.2015.07.15.15.18.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 15:18:57 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so307507igb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:18:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONAJogDgMJ45v6KLFbbe+SeDjfBFKDFv2VFC1zLJ8VGy7g@mail.gmail.com>
References: <1433419358-21820-1-git-send-email-ddstreet@ieee.org>
 <CALZtONC_-uQcE30hgzwD-V9Ps9k8g2Y_XUTjD9xcXaiXAc-hGw@mail.gmail.com>
 <CALZtONA6C3v0mwwgbf4QqLqehqtrdqs9Y=Td2-HXyhQhySki_w@mail.gmail.com>
 <CALZtOND9wWe_58PNW396dpUy_HBrr+pv5_-KNfUGjvrPiGV0Gw@mail.gmail.com>
 <CALZtONCHfcK4wUhQOiiXRL6D4fR92sKqZ+edctSZU3Xf0qWx_w@mail.gmail.com>
 <20150625133557.c519c933c104a2657417bd02@linux-foundation.org> <CALZtONAJogDgMJ45v6KLFbbe+SeDjfBFKDFv2VFC1zLJ8VGy7g@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 15 Jul 2015 18:18:38 -0400
Message-ID: <CALZtOND3CpQQCdLbTrgML5KSWtUUzXzODPt9zttXbAj7g_9BoA@mail.gmail.com>
Subject: Re: [PATCH] zswap: dynamic pool creation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 25, 2015 at 4:37 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Thu, Jun 25, 2015 at 4:35 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Thu, 25 Jun 2015 16:22:07 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>>
>>> Andrew (or anyone else) do you have any objection to this patch?  I
>>> assume Seth is on an extended vacation; maybe you could add this to
>>> your mmotm?  If Seth prefers changes to it he still has a couple
>>> months-ish until the next merge window.  I could then send the
>>> follow-on patches, that allow zswap params to be set at runtime.  I
>>> can resend them all as a series, if you prefer that.
>>
>> I'll take a look once the merge window mayhem settles down.  But it
>> never hurts to do a refresh/retest/resend.
>
> Sure, let me rebase the whole thing onto the latest upstream, and I'll
> resend the series.

Seth,

I don't know what happened, but I never got any of your replies (in my
gmail account), although I see them in the list archives :(

Just to reset everything, I'll rebase the patches and resend them, and
we can continue the discussion.  Sorry for the confusion!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
