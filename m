Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26EA7C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:27:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4752208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:27:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4752208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B5696B0005; Fri,  9 Aug 2019 07:27:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6720C6B0006; Fri,  9 Aug 2019 07:27:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52DDD6B0007; Fri,  9 Aug 2019 07:27:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00B8E6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 07:27:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so60125595edu.19
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:27:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NIRqFlTMP74ELzwtx2qB8zwdyoLcp8KikB33gmpRVvo=;
        b=M0x8lkO7NHdLA2MpyXrophnXpHVwGZn8YJ9hW46H7dzJ6mz4jgZDrixFb0VzZ+LuQP
         /unE1XIOVpMa8zbdbGbTZO5g2Bs6XvhIIn7+K/MKw7+5VpsQau8jdR6V/9VXn1tF5GLn
         t6YvytQ0Dt/o29mmxJ5G+bU5tNi8QPUOSZ40qlt6bop2pkb1zDRXxbj8g4zaljF+jAQV
         wI7HZR/DVx1Gmj7zkxkTF/mFtukZuHA9eck0PbMLKEEhvEgOWXf1jCpvCmeXiDGZ0O4d
         6DaMoTx7SiSt93S7Dp2Xy8Vxb7rRqvyWH8ROpH+Q/XFU4zDJwc5LxwQhO4rn7r27gxW2
         opJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAVqsq55RwE0FHJ+mHRRPoU0IYwbqVYN+3x1gTHw2Bj3rbLuhUQq
	NINQSzZGLz3nEKe38eVndjk3juuPXLrqjqQtV1NggQK6bPWTbit6b2vvXPiuH4MwVl0ZyuhEoQX
	r/6GSxMRaj190XZL+8URcw6yZtAbc7CrW+IwZ6PDB+VRCHj0UFeu41bDeRrH8z+mtnA==
X-Received: by 2002:a50:a56b:: with SMTP id z40mr20698379edb.99.1565350062489;
        Fri, 09 Aug 2019 04:27:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyR+QcmetT57dRYxhT1ZiQifUp6X4PcgJqvcyOznxZdd9FuSXbHc6VGzz6+b1uLvvtMyWU9
X-Received: by 2002:a50:a56b:: with SMTP id z40mr20698333edb.99.1565350061693;
        Fri, 09 Aug 2019 04:27:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565350061; cv=none;
        d=google.com; s=arc-20160816;
        b=Eu+KxFbKSn2LxMYBRfQYTfn0OljiWYy0QCvDvFEls5yrRBhJVgyw8oG0c/moO0I59v
         sFeSY/V5h1zLMgcLQQGVOAJS6wwHCWCSNw0Rs2SEJNZhPGb/P2UcofIs1QzG7bdva7Ck
         ghAdgR3wiM7AtS4hZGz3hW51uikuPop5GRGAK4d0PLmEabJyWinMJqRtrIgmFgfrFTne
         NWop7GrSpGFp1KZjbL34C8e3wIhdmK+CDUd2V8AE+wqST/odmkVcWcHKXp7QK6VFEjz0
         cqh9WdIa39bRlPnLv3MmFKu4EVYp0b0nPQ6h2HVNZ9/b/NpH8MQnl2lWbfaNdGdjRYWv
         dtxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NIRqFlTMP74ELzwtx2qB8zwdyoLcp8KikB33gmpRVvo=;
        b=swVtg+LFZCRxLsDeKhPQU/UmDUwBAgx6Q20ldPCnuk7sXXHMl+qTsK6J/F0aTzfg8X
         d2yY1B4LOC08lfDqpgbt/K9UZkdHWTAFfa77uCER0RyPLd3xjdXjV0MDxYiMruAQybv2
         uwfmTIDGCsy/BqOqSqwSHI9i2IZcQdjRoKPEveRUeQaFIwREGq7GrLHLGePCTAlfWZIX
         wNj2ytbAVFd+zIv6Q0Tnna3T2/MIHO6lK1fWNO3SdYyTw96gAGKhxqufA0oEYcOdADRy
         NozsJc1cJIEU6gxhI7C5601SpR5YztWe7g7AjrJMXI/tNBh35Iwes5vxl74vPqX/BR5N
         B9rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c19si31784029ejk.350.2019.08.09.04.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 04:27:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C52E3AD93;
	Fri,  9 Aug 2019 11:27:40 +0000 (UTC)
Date: Fri, 9 Aug 2019 13:27:39 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: Mina Almasry <almasrymina@google.com>
Cc: mike.kravetz@oracle.com, shuah@kernel.org, rientjes@google.com,
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org,
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	cgroups@vger.kernel.org
Subject: Re: [RFC PATCH] hugetlbfs: Add hugetlb_cgroup reservation limits
Message-ID: <20190809112738.GB13061@blackbody.suse.cz>
References: <20190808194002.226688-1-almasrymina@google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="IiVenqGWf+H9Y6IX"
Content-Disposition: inline
In-Reply-To: <20190808194002.226688-1-almasrymina@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

(+CC cgroups@vger.kernel.org)

On Thu, Aug 08, 2019 at 12:40:02PM -0700, Mina Almasry <almasrymina@google.com> wrote:
> We have developers interested in using hugetlb_cgroups, and they have expressed
> dissatisfaction regarding this behavior.
I assume you still want to enforce a limit on a particular group and the
application must be able to handle resource scarcity (but better
notified than SIGBUS).

> Alternatives considered:
> [...]
(I did not try that but) have you considered:
3) MAP_POPULATE while you're making the reservation,
4) Using multple hugetlbfs mounts with respective limits.

> Caveats:
> 1. This support is implemented for cgroups-v1. I have not tried
>    hugetlb_cgroups with cgroups v2, and AFAICT it's not supported yet.
>    This is largely because we use cgroups-v1 for now.
Adding something new into v1 without v2 counterpart, is making migration
harder, that's one of the reasons why v1 API is rather frozen now. (I'm
not sure whether current hugetlb controller fits into v2 at all though.)

Michal

--IiVenqGWf+H9Y6IX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEEoQaUCWq8F2Id1tNia1+riC5qSgFAl1NWKMACgkQia1+riC5
qSi2Sw/+M4XGujSB2JZaZ0/yi48MZThHdXWt5rWC6L/Nt7CW42/WhqltGcNl9c9F
O7Fegy17Qhgi0y/UUqUbQ2l27VD5AD5DZB+DIVmAIraiznhljDL24hTmSELtwOi9
Zn+c9dudCpUV4Z6LwBme2DSrsA9YAHwcjBSAhFu1YTTq07t+cT2RShx0ntKS5R9a
dYYh4JKFTsQ+qL/lWzl8aF4nYZGii7e+3i8E9+8ZYMLje6AYolAKJwQSmkWEJGGP
9asZ61GcnygJyxY4jEXo5xqUirK0c2knwT+41w1cwSto6+qdsYIYBuXueksUfMcv
LRKp/72MRdb7vHQdVQq/0uXj4QB5WAq8qFvhPbbTFgDRdMIyxUlltuLSCZ4oEKWK
TdDK/cfyowjrTbcqydWHLhX2R711IlpP2g1gGBa4nHHnXssOMTBrUthuSpX8EPUZ
YxDV4IQFEDCNxFsqsDJqd6mCZxm/Wdb+0LYz7Hi7Dqrs47bp+ggp3gYkVxFiZSsj
MzbjDYwrxdMgv6SS2P/IGUJI0Duzx3PjArGCAkYO5mjsi6HvfsF9l+pIRbb3uejC
EsWo/ReGFPTKmogjoAX4vxCRg1LpktYtzIzpqWqVTmWL70jiLnV4+FmeWBijlAJU
3TJwzTYrBbizqKm/PSjakNr9+3bBc+Tq2ZBcnq0bewC8hJZzdls=
=q8Ru
-----END PGP SIGNATURE-----

--IiVenqGWf+H9Y6IX--

