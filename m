Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3066C606C5
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:30:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77559216FD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:30:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jHtVNZux"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77559216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DFA58E0028; Mon,  8 Jul 2019 13:30:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06A178E0027; Mon,  8 Jul 2019 13:30:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4BE08E0028; Mon,  8 Jul 2019 13:30:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEC7C8E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:30:58 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id w6so10270538ybe.23
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:30:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=uAosH4rcWhCpsYgdv7tD56ho8lbt2DTohfs/exVueGE=;
        b=SqMPBedfgtNT/2mrwutffwnjFz/4j7lc581rQSEz1JUwhynwmPoxxI+XCsuCUMbrJQ
         wz0IuXccvx7bb1sMH434w8rEOiRJ3/JM3bOsEGlDTwJn5elLG8J7GF92ngyriRpkaPT+
         8F/WacpxJAE3cqAVlpEkuLg6Kf2YR7MXfrSXoGXgNCNA+gAckEyQ4jmnN12YvYxTDYWx
         h9x3Q9LVpxAWnMVo1z8eI3jLjx0/eTRXzQLH0p3ChOWfZaSqttKxM+3UUeBcbwb+coXF
         xYhgymZysjIDeOlL2zKY04Gv41vuAHg7dikvPnFYnfoarHikPSoQQbZs0ZBKrACsAZSX
         gKzQ==
X-Gm-Message-State: APjAAAVOuiDWABPh4pEnWTaadd0CCx+QK8IJ5Vc/hoRobR3qYuo0c5WA
	6OcSUqOBiaqED2HEmkA2ScMAkyETDf8+1DqMxPRZzUhmRtX7zBxe5IsedMhcbO/M5hZCcYOsTZh
	3lEsJRx4ccoorjtff4Jy/yV3PkOJI1jX4q0Qa5qPJux20LUHcMxR+Q3ikmoe3893iow==
X-Received: by 2002:a25:3217:: with SMTP id y23mr11305288yby.320.1562607058537;
        Mon, 08 Jul 2019 10:30:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqIEzPjzvN6nDpr2FfTHAjnq6nbbZjjjFEzaVtVwgGvnNQyF+Zd+OCx/cBoHkQVIN8EPu8
X-Received: by 2002:a25:3217:: with SMTP id y23mr11305244yby.320.1562607057946;
        Mon, 08 Jul 2019 10:30:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562607057; cv=none;
        d=google.com; s=arc-20160816;
        b=LaxYTMfweXBTJqjyLB0aCXKoAy6RDvLQWz8+bLgwgnSoLrgYSHEvBiKJFWSEZm6XCg
         U2Fu/xTGJogibe/xmtrclq+wpd7qp8iMyeNsd4iBLbYjmlfUB67ghjXI2aSOZGGue6v5
         8UU2FTBP4+4W6mfaDB6sMRhuxEFa4Qrfj3op2gjYK5lwuNAL8N8a/lRODu2vXYz8eD9I
         yIXFh2OtgzkDNQPLOXKIDkFx7J5acXYJPOBrqx5YiNhlN76/AD05IvcWSrPI7u5IwHuh
         h2n0W5x0xmroan62cIMVT6OExTAvE7AmWqFeOgWSM+tlqKdSyQ8Sur+DYXTPmU4a29pi
         vcVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=uAosH4rcWhCpsYgdv7tD56ho8lbt2DTohfs/exVueGE=;
        b=ZHQ+Ww5O/xbUw9CBnXXomPySKV3YVYLHKgl86w/852zpx81oy1pMk2IS93Q7uezEJH
         f0Pmw1h8jKm6JfKsIS5kimmJgVk1/Shn4WpGckkm5m6aYB5yp32Ny55y0OoYzw+xMGkF
         +Mcu/l2dL7Sd8uqDEHWca0rbq9nqEIuJJRcxsrevP9yP53dpaiGxDRYw8jc582epQZB1
         fWslgh0NpMTuNHRUh96fTGxTEn3wJgZDlRe27r2BrYcTJIwRaW1nIoCMqZP6gpJqi8WF
         0icyJ2LavNNX6KCKFloYHC0kJ/2NaFkAWffqBkvV6K2wAPnJAdiKcDiXFI0jMAUhTlIx
         uV2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jHtVNZux;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id p201si7147842ywg.415.2019.07.08.10.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 10:30:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jHtVNZux;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d237dcc0001>; Mon, 08 Jul 2019 10:30:52 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 08 Jul 2019 10:30:56 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 08 Jul 2019 10:30:56 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 8 Jul
 2019 17:30:55 +0000
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
CC: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <20190703220214.28319-1-hch@lst.de>
 <20190704164236.GP3401@mellanox.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <41dbb308-fc9e-d730-ffb0-6ce051dff1e1@nvidia.com>
Date: Mon, 8 Jul 2019 10:30:55 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190704164236.GP3401@mellanox.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562607052; bh=uAosH4rcWhCpsYgdv7tD56ho8lbt2DTohfs/exVueGE=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=jHtVNZux6j3btAC9zECxouW2X2X+bK1i9oF4C4A/Q9DWBR6i+sgDlWhjq9OHySob+
	 NKYQ+ttlZ144MP71OeW7R8RFbx3dpzYZtDFxJ4U8MMtirXaSFOMFf5Wrr/ALyvn0NV
	 ImhfP70z7sKEnSBaWwJDHhcwMQ7Lzp2xgBPbUa5ma7/wScK0abV/JFCWJFKePtyEiY
	 3wz80LEdu5nuw/rDGedPWDuwfuYUC1cP3J4H+C0Ewt3gXjrcCe8fQAHRVFUUmKBA3V
	 pPffYKMqtSM0gysCMdxQnW88TizXrXplVyoXYIzb8LYYAAFg8PE1kZsaKHw5TlXlOl
	 tHpsXfTMIiEcw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/4/19 9:42 AM, Jason Gunthorpe wrote:
> On Wed, Jul 03, 2019 at 03:02:08PM -0700, Christoph Hellwig wrote:
>> Hi J=C3=A9r=C3=B4me, Ben and Jason,
>>
>> below is a series against the hmm tree which fixes up the mmap_sem
>> locking in nouveau and while at it also removes leftover legacy HMM APIs
>> only used by nouveau.
>>
>> Changes since v1:
>>   - don't return the valid state from hmm_range_unregister
>>   - additional nouveau cleanups
>=20
> Ralph, since most of this is nouveau could you contribute a
> Tested-by? Thanks
>=20
> Jason
>=20

I can test things fairly easily but with all the different patches,
conflicts, and personal git trees, can you specify the git tree
and branch with everything applied that you want me to test?

