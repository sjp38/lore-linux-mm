Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C34FC6B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:17:49 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g2so99277567pge.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:17:49 -0700 (PDT)
Received: from helcar.apana.org.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id j71si4344960pgd.68.2017.03.16.09.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 09:17:48 -0700 (PDT)
Date: Fri, 17 Mar 2017 00:17:31 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 1/1] mm: zswap - Add crypto acomp/scomp framework
 support
Message-ID: <20170316161730.GA13909@gondor.apana.org.au>
References: <1487952313-22381-1-git-send-email-Mahipal.Challa@cavium.com>
 <1487952313-22381-2-git-send-email-Mahipal.Challa@cavium.com>
 <CALZtONBeS7bAjxpbLDdQj=y_tsXUX5TVCFdqbQ3LccTSa6kfnw@mail.gmail.com>
 <CALyTkE9=oU1dd+CLmBceHjeO965QYWWUk98L1MNoiwrDbpypcg@mail.gmail.com>
 <CALZtONBuQJN3Qrd-RP4_TAD=OeWNO8quPYpN+=Gsz2byAxWFPg@mail.gmail.com>
 <20170309093954.GA6567@gondor.apana.org.au>
 <CALZtONDmZ0PVHaRt5nX1Zipx0poMLiHCcmUq4wRbWW77ptHoWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONDmZ0PVHaRt5nX1Zipx0poMLiHCcmUq4wRbWW77ptHoWQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Mahipal Reddy <mahipalreddy2006@gmail.com>, Mahipal Challa <Mahipal.Challa@cavium.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, pathreya@cavium.com, Vishnu Nair <Vishnu.Nair@cavium.com>

On Thu, Mar 16, 2017 at 11:54:43AM -0400, Dan Streetman wrote:
>
> setting the ASYNC bit makes it synchronous?  that seems backwards...?

You set the ASYNC bit in the mask and leave it clear in the type.
That way only algorithms with the ASYNC bit off will match.
 
> Is the acomp interface fully ready for use?

The interface itself is ready but the drivers aren't yet.

So for now only sync implementations are available.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
