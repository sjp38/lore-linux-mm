Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2270FC282D7
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 06:47:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1C5F2146E
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 06:47:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="KWBInFJ9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1C5F2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11FBE8E0013; Sat,  2 Feb 2019 01:47:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CFB28E0001; Sat,  2 Feb 2019 01:47:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED9338E0013; Sat,  2 Feb 2019 01:47:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6A3B8E0001
	for <linux-mm@kvack.org>; Sat,  2 Feb 2019 01:47:13 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u32so11307148qte.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 22:47:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VqtZCAM8aMEkU1Vxv8nZ/3avC5flqPGIuAVx2UccIVs=;
        b=Zey0wQlVjIQS8/NhSd9zNfaTMBM8h4I6w64VmV1G6gQWvpWIXejBRmo3AjDrdWFPBe
         f/R0SiN3BLSwkcHZH0K0ajypBlaYIzTmFnDvdTcFeAwaBrsDiS7gB54rkSKWshBfAY1h
         MbYy9cPhfbG+gDw5JnpiiZeSyVhdA/3ozX7b7oFiqSNYqxkbLDq8xGI4FoYPoLeEWMCX
         9Y1VsL+zFAueCtbkhrlP/R+QsAseg1GzOKNnhI9JZqGquxOOW4GM1M094Dud/ZcGwCym
         sWHL3GnjErL77TA3mZ2zaOMroJUBUEA+Cc8+qL10pwe4/MbyVO9Cifsf9U09M3WDvKcU
         vp6Q==
X-Gm-Message-State: AJcUukcDLqEPzKNJ/HV6tndsber341A61s0daCU9DW5HWopLgeIRuFt4
	A7rlaWcjGbIhRZ+qvR4SWjyxdGi2U0zMn20/5cPU3jhpPfjKmyijV7rQ07WKNCZ93BAkB8rbCl7
	HVf9rK3Kwcgn0zERZt3pE55fui3kH9QYYL+7No/qLFc3v34Dm2UrwusL+9Xb7m6Q=
X-Received: by 2002:a0c:fd8a:: with SMTP id p10mr39931330qvr.48.1549090033544;
        Fri, 01 Feb 2019 22:47:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN44Q9UvoDydJ0sIDEaVQaYljT4n5PXZWpMLSRgZhvWz0WRmYZBGKcyArR72y/l0Dlhx9U9u
X-Received: by 2002:a0c:fd8a:: with SMTP id p10mr39931303qvr.48.1549090032829;
        Fri, 01 Feb 2019 22:47:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549090032; cv=none;
        d=google.com; s=arc-20160816;
        b=N5fxIfeCexoBcVklTRDH8kXd/XTAiE9Tf0MQbe9WbdbQLCUnQEEuWveGvMf1KUKUbQ
         82APaeUD4BO6iog9FUp6qa2DW841qPTAOmCvix7PQpXN4FWSfdGf0aPKqBC5OUsAiCh2
         Bb4afvbXjk9jv3Yu2Qvxo95lB7IV4mn5eQTHq1D479KL8vFkpS1fZ9t649ZVRLtMNH1v
         lm3MeXjNYa2OTKpcKxQbiOZYNciNj+Q2NJ1JNELWnRUVwj0SW5E0e6l47Osb5vhkqSiE
         +bZ/xoikn1xEjBvwwBVvmohpBwTIiAVtJ0mc8dIQ7eIth1I0rVV1+fn3+j2T/WDH2l6L
         J4xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=VqtZCAM8aMEkU1Vxv8nZ/3avC5flqPGIuAVx2UccIVs=;
        b=J6bzRe+B1WhuR8JDZeW6mkgz0Ov73j9O/U3w1DZRm24mhFv4JMfc1JMZL/W+cS140X
         eGgpozu1oY5S398zf0RE9h1oe5edEHMpJh/A20fWS5VUwVaYAo3AQ/Q5q3JOjDTm4d4R
         5f2fzXYYIE/lRh8eQC1uS6nBl4cvCCRSB3IlY9KHZanlYnkYDNnrZJ5OkCLHVJAGjlWK
         XYVOhlPtev6qLOOjHMhUNTF95svrIrcLgOxsZmd2due10IGpIrfLmLaYeE/tYMzdbE2Y
         yywNUK4Kf51y+mRvkd+NslpTzQNjUT7nzrHtSz1+TOIMI8QZHcKdqSdCCtU9ppnb9W8W
         z5/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=KWBInFJ9;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id l7si2069218qth.251.2019.02.01.22.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 22:47:12 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=KWBInFJ9;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 3AD2921F0C;
	Sat,  2 Feb 2019 01:47:12 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute4.internal (MEProxy); Sat, 02 Feb 2019 01:47:12 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm1; bh=VqtZCAM8aMEkU1Vxv8nZ/3avC5flqPGIuAVx2UccI
	Vs=; b=KWBInFJ9cP8LxdZoWAsVpQlQsnijmQXHeAAxS6i9jMbgd7gr1tfNmQD9C
	BX9GJ9EQQWIQ6RcHNO/h4HxbuDt1oqkHnod5YLzg+x6XjX1kyB4HiMqFiPz6fvPi
	hbF7FB/Rax9TJw64b5tjeaooXasMJyxvpyOg2yjhoHHkRss2xs9RBibMTO/dxM1t
	JT14vc+TDXdbRorDw8VOAf8Kzd5me7cZhRzjBZD55duDLQQtTFd9THk9N81ScF6e
	tUIzdOxIVHPSIh63Zb2wgWRXGYACC+qXiV+GkOqtaivHleb0e4+Y3+UA/Vnv26Us
	Dp7ZS1lJPTag2oqeDRCNpxz1yI9JA==
X-ME-Sender: <xms:7jxVXGKFOWtOnOi-wfKaYxrnCKvBoev_EoUTfqT1t-4MPiCR_GZQVw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeelgdellecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhepuffvfhfhkffffg
    ggjggtgfesthejredttdefjeenucfhrhhomheprfgvkhhkrgcugfhnsggvrhhguceophgv
    nhgsvghrghesihhkihdrfhhiqeenucffohhmrghinhepshhouhhrtggvfhhorhhgvgdrnh
    gvthenucfkphepkeelrddvjedrfeefrddujeefnecurfgrrhgrmhepmhgrihhlfhhrohhm
    pehpvghnsggvrhhgsehikhhirdhfihenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:7jxVXCtqJyryU6Sf7c-QpzrMZjPz6dXKC7CD3_x5z0vEDcuuWvszug>
    <xmx:7jxVXD1Wr8afRVXmGI4bpe48knzggg5dA306lgfHdNha9MBj9lYErw>
    <xmx:7jxVXCMXGsnu2QWpKHIR7Cx8saBOGXS4NYEBYRYrvM505VtCaMyzIw>
    <xmx:8DxVXPIXX5EOq9aRuBgST90HwtkUCZacIOyBbE4uop4XDD5TppRacw>
Received: from Pekka-MacBook.local (89-27-33-173.bb.dnainternet.fi [89.27.33.173])
	by mail.messagingengine.com (Postfix) with ESMTPA id C55F1E4078;
	Sat,  2 Feb 2019 01:47:07 -0500 (EST)
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
To: Christopher Lameter <cl@linux.com>, "Tobin C. Harding" <tobin@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190201004242.7659-1-tobin@kernel.org>
 <01000168a6e8944d-b8e72739-2611-4649-a8d2-304b98529b7d-000000@email.amazonses.com>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <ca008d08-0041-5277-e562-5212783ea6be@iki.fi>
Date: Sat, 2 Feb 2019 08:47:03 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <01000168a6e8944d-b8e72739-2611-4649-a8d2-304b98529b7d-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 01/02/2019 4.34, Christopher Lameter wrote:
> On Fri, 1 Feb 2019, Tobin C. Harding wrote:
> 
>> Currently when displaying /proc/slabinfo if any cache names are too long
>> then the output columns are not aligned.  We could do something fancy to
>> get the maximum length of any cache name in the system or we could just
>> increase the hardcoded width.  Currently it is 17 characters.  Monitors
>> are wide these days so lets just increase it to 30 characters.
> 
> Hmm.. I wonder if there are any tools that depend on the field width here?
> 

It's possible, but it's more likely that userspace parses by whitespace 
because it's easier to write it that way.

At least procps, which is used by slabtop, is prepared to parse a cache 
name of 128 characters. See the scanf() call in parse_slabinfo20() 
function in proc/slab.c of procps:

   http://procps.sourceforge.net/

Of course, testing with slabtop would make sense.

- Pekka

