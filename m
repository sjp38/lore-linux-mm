Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E53FC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:20:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1FEE2173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:20:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="kNMJMs9C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1FEE2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73D786B0003; Thu, 28 Mar 2019 19:20:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EAB96B0006; Thu, 28 Mar 2019 19:20:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B2056B0007; Thu, 28 Mar 2019 19:20:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 235296B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:20:40 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b12so136775pfj.5
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:20:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=cwvfXAmYS2xpbe/FjvzNojKYMDG/S4Ny/qLUa3K9/HA=;
        b=LFGM+7hYfxxSv8fTI9kwquoZKWSng5dCRblA7qYzUkdqB3tjJWUK8TOJJPsPqbIL7E
         KYv0bPPhluHf7CRG4mI4JWQK6qFBgJrJ9kzJzYStdFikF+i9JwxnEW68O9ZMKARQKLQP
         I/ciWsF14mEPF8B+IsP81LYccF9Zu512T9FUVvaRcjvBfVy+BeN1UusG1TJC3IzGpN3c
         EgVp1qsA/EOldqTE4Q4+FROurqVkOuuDqcAZdpqnLJaJlNrBbyllt2q/fcXcFifiNVie
         kMQ8GJkpNW+qefM8vNas9dbFlAscwjUF9FTxPevHAr9JUer140mvy/tR5ItG+pF6C+wu
         GwFw==
X-Gm-Message-State: APjAAAX1cmEDoeQQtfkFi4NYzl4Tj1Ba5XMVGpetUhVhagQvdJI0CQOY
	vIoGfRvtwDqjr+wSBB4h3K317zFjb/vi+n6g65i/BpvpJDIz3ybUTJ8DOHckclU88zd4l/ANKbL
	K3EusgY/8HCzpGU0m+eh3XXLV/tbnPoLNUlUVZ7QNYlQQGyJf3hPR6IrQqsXw/bvf5Q==
X-Received: by 2002:a63:e556:: with SMTP id z22mr8053868pgj.290.1553815239594;
        Thu, 28 Mar 2019 16:20:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPsIy8stSl+GRWqMw0p6Tj04xHiJisdvK2cKqHPjCzC0Q24XWLo2MAtlzl9kfpS+8ueyd3
X-Received: by 2002:a63:e556:: with SMTP id z22mr8053828pgj.290.1553815238965;
        Thu, 28 Mar 2019 16:20:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553815238; cv=none;
        d=google.com; s=arc-20160816;
        b=w0WlQVFFcONQm64b3CtpTbA124g396/nAoLhMTJpaeegcwH/y65ZAYgBKoJJKDoFJR
         LITddfQIOw2gJWQfp9rfZg64gO3lslAw+gGBlhjGUS6cV/GttiLdUUJCACP7IW1nWb39
         orx7AMSRdDmJWumM1znQoSYwn5PP/VbYUw9HWAHrwZ5uT3I4A6Nirz2y06Jsn+e7563X
         tYOeSgn8N5qNrJzEiVUo7gbJwZqn7vCM80jIcMvEdNOLf7vD2Tz4la/bnQGQ+dxm5R3h
         mb3dfc7HfCLxSAN2YvjD4IRXI8UDqdVuW2Y+53lfZJ1DFo4zmtJMLS7LmKDguEl3GZBP
         Y3Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=cwvfXAmYS2xpbe/FjvzNojKYMDG/S4Ny/qLUa3K9/HA=;
        b=uXCSnlr2+uaAGzaRE54DnzcQQ5JYlA9V/sxfKRDBNV1ta58tC52GhP6LnENhTeAL/E
         lA+yRdafw9KVcjAuYTN/Mw/hMYhYzTF/BShzzL5lrPBNk4AktIhwSvO27ttG4vq0DG/G
         yh1o0eeJAWNyxBceaAQC95ceaWeXqTZgnNCo03ECeXFCqPb0xM8vza6fdJfJKLaDfNdl
         nlFXGES+fY/xnaSrhDJ8QQlpI3g4tksVUT9dXIiPgjqvvgg/zlH/6AJTFwdCB+Zk7mfe
         EEA6a94z8wm6742lObg+ZXrfOMAoVKGUbXnsLATO1bZ7DYdu0QOFjtYn8oRYnQZRWnid
         1iqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kNMJMs9C;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id l33si400749pld.309.2019.03.28.16.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:20:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kNMJMs9C;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d56c90000>; Thu, 28 Mar 2019 16:20:41 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 16:20:38 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 16:20:38 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 23:20:38 +0000
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-11-jglisse@redhat.com>
 <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
 <20190328213047.GB13560@redhat.com>
 <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
 <20190328220824.GE13560@redhat.com>
 <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
 <20190328224032.GH13560@redhat.com>
 <0b698b36-da17-434b-b8e7-4a91ac6c9d82@nvidia.com>
 <20190328230543.GI13560@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <9e414b8c-0f98-a2f7-4f46-d335c015fc1b@nvidia.com>
Date: Thu, 28 Mar 2019 16:20:37 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328230543.GI13560@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553815241; bh=cwvfXAmYS2xpbe/FjvzNojKYMDG/S4Ny/qLUa3K9/HA=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=kNMJMs9C+TM1nNFTqcCV7IrVAkqxMYU++6lQG9ATbs5dJW3bohUET58V2LGYBJ3AS
	 BJOR3Wxcqu+O47jZVuo4jxeNgexPD12CKcgQqGkcjnMg7a14DNYwvxMfNWRsSBQLEg
	 PmVuCr8J6jmZ9N9JV6HxPfnhkC4PZ0lRQyjpXcUJ94q9EVm/ibBxc6wIgOfAefZI5U
	 ALdxLZSvIEDDguQNaUCnjr01WMaGnRhvhwa+gudD1FXzyCnmBQ83NvG4D7CG5Blw03
	 fRfwFvygK2kgIdrvJZK3kRGV9HlIEiUvIRIqJV8go1+5AoYHs0j3fwtpwlXsSukM1Z
	 wd9dFJcLPiWiA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 4:05 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 03:43:33PM -0700, John Hubbard wrote:
>> On 3/28/19 3:40 PM, Jerome Glisse wrote:
>>> On Thu, Mar 28, 2019 at 03:25:39PM -0700, John Hubbard wrote:
>>>> On 3/28/19 3:08 PM, Jerome Glisse wrote:
>>>>> On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
>>>>>> On 3/28/19 2:30 PM, Jerome Glisse wrote:
>>>>>>> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
>>>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
>>>>>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>> [...]
>>>> OK, so let's either drop this patch, or if merge windows won't allow t=
hat,
>>>> then *eventually* drop this patch. And instead, put in a hmm_sanity_ch=
eck()
>>>> that does the same checks.
>>>
>>> RDMA depends on this, so does the nouveau patchset that convert to new =
API.
>>> So i do not see reason to drop this. They are user for this they are po=
sted
>>> and i hope i explained properly the benefit.
>>>
>>> It is a common pattern. Yes it only save couple lines of code but down =
the
>>> road i will also help for people working on the mmap_sem patchset.
>>>
>>
>> It *adds* a couple of lines that are misleading, because they look like =
they
>> make things safer, but they don't actually do so.
>=20
> It is not about safety, sorry if it confused you but there is nothing abo=
ut
> safety here, i can add a big fat comment that explains that there is no s=
afety
> here. The intention is to allow the page fault handler that potential hav=
e
> hundred of page fault queue up to abort as soon as it sees that it is poi=
ntless
> to keep faulting on a dying process.
>=20
> Again if we race it is _fine_ nothing bad will happen, we are just doing =
use-
> less work that gonna be thrown on the floor and we are just slowing down =
the
> process tear down.
>=20

In addition to a comment, how about naming this thing to indicate the above=
=20
intention?  I have a really hard time with this odd down_read() wrapper, wh=
ich
allows code to proceed without really getting a lock. It's just too wrong-l=
ooking.
If it were instead named:

	hmm_is_exiting()

and had a comment about why racy is OK, then I'd be a lot happier. :)


thanks,
--=20
John Hubbard
NVIDIA

