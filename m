Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CF98C468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 06:23:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CCB320833
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 06:23:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HhS3RPzE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CCB320833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CE4A6B026B; Mon, 10 Jun 2019 02:23:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 831146B026D; Mon, 10 Jun 2019 02:23:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A9FA6B026E; Mon, 10 Jun 2019 02:23:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADBF6B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 02:23:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t64so4534942pgt.8
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 23:23:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=lxnikhRVrLC3Z73VDFr/xBpCYRqbKfZ/1e83VsEWBxE=;
        b=HcnsZ61zoqDCFbAfyT0jscc/zc4KKYJNoco5cTkcDEqEuWAnsCXsE2CvNi93ol8eH4
         wHN1EY0ae/AiRAKHN5aXogRFJRn3It9k3PS4NvBY6bVxfXhGcIamJjyZ9BYoFOo49hhw
         CQk1sENm/UwDs2ShqZEQzpekEXsh+y3+J0id+35JPhGcXGbsHMiD4IMeNON0ncvkoyGE
         wIUEmrfqGCAwlxGZkEdee/j2M9PVTDnD6T8muVO6OF2iofFzlhDesONLKfwv3E+A1a/T
         X6Ui6tz5mkOEAYVgTRV73FJV0v+vtcj/XBONO33WAQMT0r5QIaLRBTcChCW5C98h+f74
         4nTw==
X-Gm-Message-State: APjAAAWLZY+jfVs04gpekb0N+VH8JDvCcBuVKtsYOI9Z4epak3gzZDyC
	vv/RJRKM5RqoxzAB3LLBsBLsl6FfSsK7ZOujAMQYSd28KzsQFAj8Lsd6FKrGTZNrJmLvc0hC9CO
	bihAxS9Ood52paR1WSIACob+uvtdqpJUhwpLNNFzT9es6/VwqJEVOHFo2uShyHcE7YQ==
X-Received: by 2002:a62:1990:: with SMTP id 138mr72802743pfz.133.1560147819772;
        Sun, 09 Jun 2019 23:23:39 -0700 (PDT)
X-Received: by 2002:a62:1990:: with SMTP id 138mr72802709pfz.133.1560147819149;
        Sun, 09 Jun 2019 23:23:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560147819; cv=none;
        d=google.com; s=arc-20160816;
        b=hB7uWitX3MBq7VYhM6Qkw8k5l9AN9XT99sNRavJCHoO6sTeMkkTSzzz/dX7VPWXjxI
         gH7TzAOXNPTL9nnG3clVBretiKXjoLoUi6FeUYLcDSXBIzyJPaXEONVCkCfXD5kI9fE6
         FZmUXhEhnsCMlEibwYzA+7fIPlCI82tlcWV0zoeJoYuPCeysauRI3YZLK96F/SPfKPjO
         xWT4QL84hIXLTlRK47gnQVFszDUwDCD+7ixo54Ujhvni0X4nO7Ny06X6jUu8plQFxyAk
         /UqrMPRzULayRJ+QBjI2OjT4NIwGRJrk0noeTDegImJFt0ASJp+OLrVuMjlP3ses9YKo
         2DJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=lxnikhRVrLC3Z73VDFr/xBpCYRqbKfZ/1e83VsEWBxE=;
        b=dluOfkoWV1agV2u8qXa7FNKjAc2LszlTfWbaeD7nOa50EPwuMbF1XbdLsd2EGP2ftJ
         v8LNwATXBgToSSSYdCTA2EkhdM4+Dmwrl0FuFSqIZqwd1yJi9xts1MOEdzF4Qx75CN+4
         tLGLPXsnj0st9vELheXFfPWPiSWGSxXC9brEOEfPf4VxJTgQGNEtvSNxMFpdAwdrMBwq
         nTedgNERh7b2hMJJMUAADjEOz178zphdqhR67v2S3JYnqlqKe3xK6kVtqcmlo/nqQEi8
         qqExDNxp5D+uqqfOpeI1AGRpYqmQrYJpDgJVhIrti4QCClW1+ypKOwdW2w9grqj34xMq
         RL/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HhS3RPzE;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 127sor9064474pfc.34.2019.06.09.23.23.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 23:23:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HhS3RPzE;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=lxnikhRVrLC3Z73VDFr/xBpCYRqbKfZ/1e83VsEWBxE=;
        b=HhS3RPzEgNDje8ZeE1beB7YaEgCu7QXAMpLFxSnCvGu25AyoYFquLZjcQ9HS35cUHX
         OjJrIJNYihJovEDfKK7wREuQr6mX3fB/p+JMid/mCa450vk23OoTJr5PP8FLnAZCO0aa
         qZ/bB+1jKDDhnGobtz7oFe0mRjdxrsdGDVqCLxKtBZf6e4EOBP9YKmTkH9JsHMZeGCXE
         2pDr+73d3GfR+18xpVN9GWeSJ38ufuoTNbG7RsahD3eXWksL0ALWJ8NUM/q9fEgYy6fA
         CMlvOIEQQ3JYF08bPoCo+zTzYVoLdPgpnp1YHL+Z5oKAZ7GZTyv5lT8vFPLsrf3CCIwO
         pG0w==
X-Google-Smtp-Source: APXvYqzkDxHd9EVmOstnNeKlU2BwYtI5fqWFffgbDeETtbK8xN0ov7dak0twrcQF3n8lvJidVKHyRg==
X-Received: by 2002:aa7:8c52:: with SMTP id e18mr3569440pfd.233.1560147818885;
        Sun, 09 Jun 2019 23:23:38 -0700 (PDT)
Received: from localhost (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id i3sm9824804pfo.138.2019.06.09.23.23.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 09 Jun 2019 23:23:38 -0700 (PDT)
Date: Mon, 10 Jun 2019 16:21:16 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 1/4] mm: Move ioremap page table mapping function to mm/
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<03de53e9-f1f9-1632-567e-b88aabc56764@arm.com>
In-Reply-To: <03de53e9-f1f9-1632-567e-b88aabc56764@arm.com>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560147293.7fxg58sp20.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000277, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual's on June 10, 2019 3:42 pm:
>=20
>=20
> On 06/10/2019 10:08 AM, Nicholas Piggin wrote:
>> ioremap_page_range is a generic function to create a kernel virtual
>> mapping, move it to mm/vmalloc.c and rename it vmap_range.
>=20
> Absolutely. It belongs in mm/vmalloc.c as its a kernel virtual range.
> But what is the rationale of changing the name to vmap_range ?

Well it doesn't just map IO. It's for arbitrary kernel virtual mapping
(including ioremap). Last patch uses it to map regular cacheable
memory.

>> For clarity with this move, also:
>> - Rename vunmap_page_range (vmap_range's inverse) to vunmap_range.
>=20
> Will be inverse for both vmap_range() and vmap_page[s]_range() ?

Yes.

>=20
>> - Rename vmap_page_range (which takes a page array) to vmap_pages.
>=20
> s/vmap_pages/vmap_pages_range instead here ................^^^^^^

Yes.

> This deviates from the subject of this patch that it is related to
> ioremap only. I believe what this patch intends is to create
>=20
> - vunmap_range() takes [VA range]
>=20
> 	This will be the common kernel virtual range tear down
> 	function for ranges created either with vmap_range() or
> 	vmap_pages_range(). Is that correct ?
> - vmap_range() takes [VA range, PA range, prot]
> - vmap_pages_range() takes [VA range, struct pages, prot]=20

That's right although we already have all those functions, so I don't
create anything, only move and re-name. I'm happy to change the
subject if you have a preference.

> Can we re-order the arguments (pages <--> prot) for vmap_pages_range()
> just to make it sync with vmap_range() ?
>=20
> static int vmap_pages_range(unsigned long start, unsigned long end,
>  			   pgprot_t prot, struct page **pages)
>=20

Sure, makes sense.

Thanks,
Nick

=

