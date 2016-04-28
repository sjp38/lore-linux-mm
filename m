Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49AF56B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 07:35:47 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so61968061lfq.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:35:47 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id g5si18735832wmf.67.2016.04.28.04.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 04:35:46 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id e201so73022741wme.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:35:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160427123139.GA2230@dhcp22.suse.cz>
References: <9459.1461686910@turing-police.cc.vt.edu>
	<20160427123139.GA2230@dhcp22.suse.cz>
Date: Thu, 28 Apr 2016 13:35:45 +0200
Message-ID: <CAMJBoFPWNx6UTqyw1XF46fZYNi=nBjHXNdWz+SDokqG3xEkjAA@mail.gmail.com>
Subject: Re: Confusing olddefault prompt for Z3FOLD
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Apr 27, 2016 at 2:31 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 26-04-16 12:08:30, Valdis Kletnieks wrote:
>> Saw this duplicate prompt text in today's linux-next in a 'make oldconfig':
>>
>> Low density storage for compressed pages (ZBUD) [Y/n/m/?] y
>> Low density storage for compressed pages (Z3FOLD) [N/m/y/?] (NEW) ?
>>
>> I had to read the help texts for both before I clued in that one used
>> two compressed pages, and the other used 3.
>>
>> And 'make oldconfig' doesn't have a "Wait, what?" option to go back
>> to a previous prompt....
>>
>> (Change Z3FOLD prompt to "New low density" or something? )
>
> Or even better can we only a single one rather than 2 algorithms doing
> the similar thing? I wasn't following this closely but what is the
> difference to have them both?

The v3 version of z3fold doesn't claim itself to be a low density storage :)
The reasons to have them both are listed in [1] and mentioned in [2].

Thanks,
   Vitaly

[1] https://lkml.org/lkml/2016/4/25/526
[2] https://lkml.org/lkml/2016/4/25/570

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
