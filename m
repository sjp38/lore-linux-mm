Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C70C96B0264
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 11:25:54 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id l68so155347913wml.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:25:54 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id n66si25139879wmb.52.2016.03.15.08.25.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Mar 2016 08:25:53 -0700 (PDT)
Subject: Re: Page migration issue with UBIFS
References: <56E8192B.5030008@nod.at>
 <20160315151727.GA16462@node.shutemov.name>
From: Richard Weinberger <richard@nod.at>
Message-ID: <56E8297E.80708@nod.at>
Date: Tue, 15 Mar 2016 16:25:50 +0100
MIME-Version: 1.0
In-Reply-To: <20160315151727.GA16462@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Kaplan <alex@nextthing.co>

Kirill,

Am 15.03.2016 um 16:17 schrieb Kirill A. Shutemov:
> On Tue, Mar 15, 2016 at 03:16:11PM +0100, Richard Weinberger wrote:
>> Hi!
>>
>> We're facing this issue from 2014 on UBIFS:
>> http://www.spinics.net/lists/linux-fsdevel/msg79941.html
>>
>> So sum up:
>> UBIFS does not allow pages directly marked as dirty. It want's everyone to do it via UBIFS's
>> ->wirte_end() and ->page_mkwirte() functions.
>> This assumption *seems* to be violated by CMA which migrates pages.
> 
> I don't thing the CMA/migration is the root cause.
> 
> How did we end up with writable and dirty pte, but not having
> ->page_mkwrite() called for the page?
> 
> Or if ->page_mkwrite() was called, why the page is not dirty?

Thanks for your quick response!

I also don't think that the root cause is CMA or migration but it seems
to be the messenger.

Can you confirm that UBIFS's assumptions are valid?
I'm trying to rule out possible issues and hunt down the root cause...

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
