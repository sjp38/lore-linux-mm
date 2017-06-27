Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 119EB6B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:38:12 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 64so6820821uag.8
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:38:12 -0700 (PDT)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id v7si1004738vka.106.2017.06.27.00.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 00:38:10 -0700 (PDT)
Received: by mail-ua0-x229.google.com with SMTP id j53so13701118uaa.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 00:38:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <13ab3968-a7e4-add3-b050-438d462f7fc4@suse.cz>
References: <594d905d.geNp0UO7DULvNDPS%akpm@linux-foundation.org>
 <CAC=cRTNJe5Bo-1E+3oJEbWM8Yt5SyZOhnUiC9U5OK0GWrp1E0g@mail.gmail.com>
 <c3caa911-6e40-42a8-da4d-45243fb7f4ad@suse.cz> <13ab3968-a7e4-add3-b050-438d462f7fc4@suse.cz>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Tue, 27 Jun 2017 09:38:09 +0200
Message-ID: <CAKwiHFjfrWqa+0NhL1EHKJwmghrL52Xzn-tYJsOi1B41shCsTg@mail.gmail.com>
Subject: Re: mmotm 2017-06-23-15-03 uploaded
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: huang ying <huang.ying.caritas@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz, Mark Brown <broonie@kernel.org>

>>
>> However, the patch in mmotm seems to be missing this crucial hunk that
>> Rasmus had in the patch he sent [1]:
>>
>> -__rmqueue_fallback(struct zone *zone, unsigned int order, int
>> start_migratetype)
>> +__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>>
>> which makes this a signed vs signed comparison.
>>
>> What happened to it? Andrew?

This is really odd. Checking, I see that it was also absent from the
'this patch has been added to -mm' mail, but I admit I don't proofread
those to see they match what I sent. Oh well. Let me know if I need to
do anything.

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
