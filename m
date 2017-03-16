Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A79A06B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:21:38 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a6so29969263lfa.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:21:38 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id k20si3116961lfi.144.2017.03.16.11.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 11:21:37 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id v2so3971218lfi.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:21:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170316163331.GA13997@gondor.apana.org.au>
References: <1487952313-22381-1-git-send-email-Mahipal.Challa@cavium.com>
 <1487952313-22381-2-git-send-email-Mahipal.Challa@cavium.com>
 <CALZtONBeS7bAjxpbLDdQj=y_tsXUX5TVCFdqbQ3LccTSa6kfnw@mail.gmail.com>
 <CALyTkE9=oU1dd+CLmBceHjeO965QYWWUk98L1MNoiwrDbpypcg@mail.gmail.com>
 <CALZtONBuQJN3Qrd-RP4_TAD=OeWNO8quPYpN+=Gsz2byAxWFPg@mail.gmail.com> <20170316163331.GA13997@gondor.apana.org.au>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 16 Mar 2017 14:20:56 -0400
Message-ID: <CALZtONAjUCLceJMGQ5OD+vT3CqzywgU2JC5L2KWhJpA3nxng7w@mail.gmail.com>
Subject: Re: [PATCH v2 1/1] mm: zswap - Add crypto acomp/scomp framework support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Mahipal Reddy <mahipalreddy2006@gmail.com>, Mahipal Challa <Mahipal.Challa@cavium.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, pathreya@cavium.com, Vishnu Nair <Vishnu.Nair@cavium.com>

On Thu, Mar 16, 2017 at 12:33 PM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> On Wed, Mar 08, 2017 at 12:38:40PM -0500, Dan Streetman wrote:
>>
>>
>> setting the ASYNC bit makes it synchronous?  that seems backwards...?
>
> You set the ASYNC bit in the mask and leave it clear in the type.
> That way only algorithms with the ASYNC bit off will match.

aha, ok i get it now.

>> zswap gets the fun of being the first crypto compression consumer to
>> switch to the new api? ;-)
>
> BTW I think we should hold off on converting zswap for now.

ok that sounds good, we can wait.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
