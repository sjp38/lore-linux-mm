Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7847C169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 23:35:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77B42217D9
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 23:35:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="tjW1ZUZl";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="TXHjnFR+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77B42217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7BAD8E002B; Sun,  3 Feb 2019 18:35:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2B5C8E001C; Sun,  3 Feb 2019 18:35:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1AD38E002B; Sun,  3 Feb 2019 18:35:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 943548E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 18:35:05 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id z6so16811845qtj.21
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 15:35:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aoP2mmLS0fFDf6FMYYWWgGtGUnpH6xQLxrW4GZ1ymV8=;
        b=L1P0V8UhjpUCrAZ8si0e44v+ZsW33GcousGnUKvJ5U3+KMcIsLj3ED9u7yuk++coE/
         2LRe5ktqxu/CJet7ApwYLsuXzku3TDPoO1oM0i6b5ugbL34Ddey/+pYQQQRm8OsCS/oc
         prDJiM1vxuHOvOxPbOKrYe+lzC58NLLrvzCXlmeD88d7fr2yaZljH7kzB4L4ZY5AHlZl
         NadGGecJsgbOaWRUCAALDw7R59ynRsCFo/uVchg0IMiRnV+U3VDoPZg8pEPAyKpwAWaa
         xzTNpwsVIFWBakvYFe4VysMOSI9LgQz9G4kb8KXi8FTFbC4h8WR8gEEN47gBst9BuS5F
         dEDg==
X-Gm-Message-State: AJcUukeMmNkXoRoGntquyFma6w1lhbuAPX1FyvePG5+bCD5iDqmkdW9H
	LmFbDQ4yu89aoGgIB6gPNJhz7ISIjk8JXN54hntWbBLsHVU7Ipmlxp1camDw07AwH9cq5jSU2dR
	gvKD/hLujvEt93cddmzsQ6SX89Cm3yjxNN/Espxmqm9gaxUvknLZQIOJ+2zMSWmiToA==
X-Received: by 2002:a0c:d792:: with SMTP id z18mr46306582qvi.183.1549236905365;
        Sun, 03 Feb 2019 15:35:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7sMCwdMq/fSe1pi71al/ZM0iEpFSawUqd3BOQdYqWhs9DqtEcRRtTbHUZIAmj6YHMVTMYa
X-Received: by 2002:a0c:d792:: with SMTP id z18mr46306561qvi.183.1549236904734;
        Sun, 03 Feb 2019 15:35:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549236904; cv=none;
        d=google.com; s=arc-20160816;
        b=Ga5Sl92Gba1TQEr5J9xFSmdEFeFQjc4rmamb9eSPGjAI6A211E5iawSPBY84dXw2Gf
         bGxcgRIJNIawBn1AEN//bEzvmJfIYJWWiVInD8jS5DFSiIOQFjzOmbRldI/0r5wBHsjb
         SUVEODUgEeWx6UWpk5Ng+l4MIC73KZHYV+dVRaRJht12oNsX2ZLkhI6vyvPcJCTDaG2k
         PPpvhI0CokucwVr8ITI5yi46DI5GKjVtFQd3NrV3P3Zp5IR4k0hctbrPe2AYQ1DXTPdu
         Oh/kez9g3vJyezgkvZoN2gpeJOAdnf2VlpS9UX/ShSVH5mQdxzj/7fqosRxhDyXxi64N
         Ng0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=aoP2mmLS0fFDf6FMYYWWgGtGUnpH6xQLxrW4GZ1ymV8=;
        b=teH2wvnRJt9aIuwnuuZ21UMdp5nQGTqpGf6ZP5CglU3VsTJpsNqoUt6u/fJAAjv25r
         EzLN3ymkcqCgk73BhnsIKYup7x3t2NFT4WCV7kvyHmfg+m54qNvghhrMUA6Yot1qk8OK
         zOfi4/cGJJicAoZUEBrrhQv3n2b3ukVCKPP/NgDykqE8VNGELy7sm8CY0v6jnPcZ4bTZ
         HjxwMoiuDNAyydU8V6NEleq9VAVYTJ4AJZHfZgDJohtGHPVuH7VoQDoKE8BuMMbcvH/M
         UwVtAUqsWRj5MwZUEtbnGiiXCDGJAJMRRw0l0pN/RVjFHw6bg8R9i0jXEn6KZCOoaIKv
         Nqwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=tjW1ZUZl;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=TXHjnFR+;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id o27si983374qto.166.2019.02.03.15.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 15:35:04 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=tjW1ZUZl;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=TXHjnFR+;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 4B6BD211EC;
	Sun,  3 Feb 2019 18:35:04 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Sun, 03 Feb 2019 18:35:04 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=aoP2mmLS0fFDf6FMYYWWgGtGUnp
	H6xQLxrW4GZ1ymV8=; b=tjW1ZUZlm8KjR6ekFNqiWeKR5CEbDh5ZFaO6Ax6QEQ3
	X2BZQgoXfnnwZM7N5+ksjVJLOu5r+16BjpoJbqJjfxuKVpKK4ipKYkJpbRlyAzS8
	IYsn0OwCQdsTjdOosjJ6Q5QF8ITAnXBf1U/b3Qfl2msC46kzkN7DbcjNZeEib4+U
	lkkbVeUYooz8F+F8BkMc5nUeCdnd3pJ+5k2T5Fnh7XVZTumYv2sKdtFSM0UbIFyo
	3fvVNmhPnVJJef5THh7tY2gea2bZJ/46FuKlaipBwHZRSBDxZ4oFj21ceB8jlF1q
	oMSIT2RuCJiPYo8BnYXbf0Htl1t3hUUHH0M9rCeu6ng==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=aoP2mm
	LS0fFDf6FMYYWWgGtGUnpH6xQLxrW4GZ1ymV8=; b=TXHjnFR+BCdxaGS6LY3rUl
	iRVQXI4U+mcXoME0gcYdJa8zMwyHU+sDywLpQkftICc/ZBOxducYWTVOsQEx7LZ8
	JpqTjcs3sLsp2rqOmjImYIRLeZ9TshhBt/ef9WsicMdji72mRDsCFAAYx8sfvy1p
	SJxABSf4UxNE62v/8NEHi/AhMMYTzdm+hYyPOdexxAyvoogCOPRFA5WwJTO9kzBS
	vBa01nWpSV0M+lCWKlEGbg+E2lwMzSlnikdS8fDUJWTcJvhVBewb8C03ozOIhP++
	vVEoVqb69hfT+x6ajBULuhJa0L3Ka+BKlTicVbSoMVG8w55/iOmuJ4mHecsWigkw
	==
X-ME-Sender: <xms:pnpXXC35hBDjlvIt-_Wo8D8SgW70ZdnhpqccpQhT2Ji9wVkdjeHD9A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeefgdduudcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpeffhffvuffkfhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfv
    ohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppe
    duvddurdeggedrvddvjedrudehjeenucfrrghrrghmpehmrghilhhfrhhomhepmhgvseht
    ohgsihhnrdgttgenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:pnpXXPVckP-yFUnf1l4PLp9Erc4Wx6h_bNvnSfNu093BZ3WIhdqZCw>
    <xmx:pnpXXENVGUUcAvBGbb85DD07GRINm6ZjpKFtneo1RXsJRLlt5BAzIw>
    <xmx:pnpXXHJtItG9u_6k4HgK_PQIK3mFuLR6Q7o5IZOjasjbQblzmUFp-w>
    <xmx:qHpXXIOs6rPNqgublhJcaf6SaRo_zXrew4lFCpqiDUNX94Icf_i7ag>
Received: from localhost (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5A94DE44A8;
	Sun,  3 Feb 2019 18:35:01 -0500 (EST)
Date: Mon, 4 Feb 2019 10:34:54 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Joe Perches <joe@perches.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-ID: <20190203233454.GB4235@eros.localdomain>
References: <20190201004242.7659-1-tobin@kernel.org>
 <089b1025c5e81410b6b608290becd6f609ca03b4.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <089b1025c5e81410b6b608290becd6f609ca03b4.camel@perches.com>
X-Mailer: Mutt 1.11.2 (2019-01-07)
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 07:27:24PM -0800, Joe Perches wrote:
> On Fri, 2019-02-01 at 11:42 +1100, Tobin C. Harding wrote:
> > Increase the width of the first column (cache name) in the output of
> > /proc/slabinfo from 17 to 30 characters.
> 
> Do you care if this breaks any parsing of /proc/slabinfo?
> 
> I don't but someone might.

Thanks for looking at the patch Joe, Christoph pointed this out also.
Solution is going to take a different approach and not touch the column
width in /proc/slabinfo for the record, although it does not really
matter now, I think that anyone parsing /proc/slabinfo would be using
whitespace because the name field is already variable length.

Anyways, new patch to come.

thanks,
Tobin.

