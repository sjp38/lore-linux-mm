Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8F296B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:33:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e129so93943971pfh.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:33:44 -0700 (PDT)
Received: from helcar.apana.org.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id s15si5816262plj.27.2017.03.16.09.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 09:33:43 -0700 (PDT)
Date: Fri, 17 Mar 2017 00:33:31 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 1/1] mm: zswap - Add crypto acomp/scomp framework
 support
Message-ID: <20170316163331.GA13997@gondor.apana.org.au>
References: <1487952313-22381-1-git-send-email-Mahipal.Challa@cavium.com>
 <1487952313-22381-2-git-send-email-Mahipal.Challa@cavium.com>
 <CALZtONBeS7bAjxpbLDdQj=y_tsXUX5TVCFdqbQ3LccTSa6kfnw@mail.gmail.com>
 <CALyTkE9=oU1dd+CLmBceHjeO965QYWWUk98L1MNoiwrDbpypcg@mail.gmail.com>
 <CALZtONBuQJN3Qrd-RP4_TAD=OeWNO8quPYpN+=Gsz2byAxWFPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONBuQJN3Qrd-RP4_TAD=OeWNO8quPYpN+=Gsz2byAxWFPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Mahipal Reddy <mahipalreddy2006@gmail.com>, Mahipal Challa <Mahipal.Challa@cavium.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, pathreya@cavium.com, Vishnu Nair <Vishnu.Nair@cavium.com>

On Wed, Mar 08, 2017 at 12:38:40PM -0500, Dan Streetman wrote:
>
> zswap gets the fun of being the first crypto compression consumer to
> switch to the new api? ;-)

BTW I think we should hold off on converting zswap for now.

The reason is that I'd like to try out the new interface on IPcomp
and make sure that it actually is able to do decompression piecemeal
which is the main advantage over the existing interface for IPcomp
where we allocate for the worst-case (64K vs average packet size
of 1.5K).

In that process we may have to tweak the interface.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
