Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 969F5C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:22:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38E1E20883
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:22:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=gmx.net header.i=@gmx.net header.b="BIQFrDlq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38E1E20883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C64176B000A; Mon,  8 Apr 2019 11:22:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C13196B000C; Mon,  8 Apr 2019 11:22:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B03876B000D; Mon,  8 Apr 2019 11:22:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6681D6B000A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 11:22:41 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u6so8669484wml.3
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 08:22:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=/yghZh/zk1w5fqKSE/H9RmSiHIPc58wpoy1raaEo4Wg=;
        b=VFdrF4MTz15l8FUsyL0dFepVdzlUbq9wBeCT3ehTk1wijQT+dL1WpTZz/qCM9VYz/X
         sEKxRVT8dlFOtHg0zKZVRMKwdvlFjm8kI1z88mbH0zVYKbnYDmJKEjPvw92n1gxyBIWP
         x+0DrQukv8CORtsm3t9oEbVdbj/ttUUdtLbq93UjsUsd9wp8/Scm1IvYYWO3IzLEEQks
         QSvB4f3m1T15ksEm3zLUdCfmGryiJ66sApPwA54zhKkFE7u9hfsHqjt/P58GG50kTWRr
         dYlsWhOY9LVAWoJvwjl4z48Bizayg/XXPoB8ayUPK6xGHf3D2oL6AUFFQdoYYMadi8zd
         UAHQ==
X-Gm-Message-State: APjAAAXLy5U5fd0QZxtWM+ZnGHDffL6N1KoHX+xDPhURYsw35MIXb+y+
	94TrGGEHuVanLriyBYihMPVXwko40BjenpMBkaKdrAOgFrGi5dUXZJhKJfontmYc4IJaLbcl3kl
	TMrIk+8yczoz72GR2nSfmDgoZIZ4IYoO2/mYImCv1BXtOE8I6+Xj3wfWcF/4Z+bQOZA==
X-Received: by 2002:adf:ff91:: with SMTP id j17mr20208772wrr.114.1554736960931;
        Mon, 08 Apr 2019 08:22:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCi8pP7bep+6M3iz+QXGSoS6dd/Trpf+XbIfgjusKoz3aD/YgtZE72B2WFkfEKzvlYPier
X-Received: by 2002:adf:ff91:: with SMTP id j17mr20208726wrr.114.1554736960225;
        Mon, 08 Apr 2019 08:22:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554736960; cv=none;
        d=google.com; s=arc-20160816;
        b=rr7xNTsDQya8RwIeCYJsYctG6d7SxnV8Z4oep4EUrtiVCPuABmPlBtOCJrxsHFvn2c
         SSQm55wrZrXOhYJziakF5RL1fh25cuYwZM0+GiQX656xMfKaYgStkxies7RCdGNPnshW
         A2pAH6JILA4E+eI64gbWLpUq5bSCx8owohyxh/OK0+YThnBo+XNNnhmILZc90VAEOZRF
         aa3pycQ2p70C4nVW24j4CwLOUoQTtnyhIWtsqnjvlB00yvaoe6e6o0myPewXWc+XVY5Z
         Xx79IbF+X0e0hZ32mhdOAUHuNiMaRnXPfckK27UYuYH36zwB/ADn86MV5TfvYCaFqiG7
         ONbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=/yghZh/zk1w5fqKSE/H9RmSiHIPc58wpoy1raaEo4Wg=;
        b=rp6E8DazohzytxO39ZZX38NLP4KHmpE7e4aOQLkm+74oPnPxH2pniMzUWUXtRUqmxS
         lAqgD+0qAbRAyN7qZIcP3Wy5LYl84LUyT7wN7ZoZ8ji2eqeFO8xi+N/baNBUcv9R0zbw
         +9KIw2E9Zn7BdsGNHIhqLwKPqCRemfXPF+diVqerXutqIWhZbevIBqjmoZhzOxkap5h6
         gRxbCSGhSv2ZYTQTBACPme4LIXuIY8V9jEPG2xc19M6CpNz6MnoYB1dAtAyHPtYrMLFL
         A2WIw/S2sWoFPdQZYTwHJHZat2AniNjaKhNTik7siS7fLDThS82/2dr8yO83WLXUOgJl
         4mhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmx.net header.s=badeba3b8450 header.b=BIQFrDlq;
       spf=pass (google.com: domain of deller@gmx.de designates 212.227.17.21 as permitted sender) smtp.mailfrom=deller@gmx.de
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id b123si6956084wmg.96.2019.04.08.08.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 08:22:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of deller@gmx.de designates 212.227.17.21 as permitted sender) client-ip=212.227.17.21;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmx.net header.s=badeba3b8450 header.b=BIQFrDlq;
       spf=pass (google.com: domain of deller@gmx.de designates 212.227.17.21 as permitted sender) smtp.mailfrom=deller@gmx.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gmx.net;
	s=badeba3b8450; t=1554736955;
	bh=YQ7Dd9MnQQ+99bmZDYVmOzVyL+EmFBmVD01ZrLWKZtE=;
	h=X-UI-Sender-Class:Subject:To:Cc:References:From:Date:In-Reply-To;
	b=BIQFrDlqn3A+WlzsYGzOpdGMDmqNf+y23QQqK2wgeF92sCMlMm62i4vfM9wb70tHR
	 iCHv0gPGp9LxhWC/2Los8cF4z5DeXyemoItJan6DdZZwybogVS31/Jci7/5hTZfxjc
	 Xuy2F7Hvo29X0RREU8sSRC4XS+U4NvlVZP7idr+o=
X-UI-Sender-Class: 01bb95c1-4bf8-414a-932a-4f6e2808ef9c
Received: from [192.168.20.60] ([92.116.135.228]) by mail.gmx.com (mrgmx102
 [212.227.17.168]) with ESMTPSA (Nemesis) id 0Ls7MZ-1glEIu0MN5-013zGO; Mon, 08
 Apr 2019 17:22:35 +0200
Subject: Re: Memory management broken by "mm: reclaim small amounts of memory
 when an external fragmentation event occurs"
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
 Mel Gorman <mgorman@techsingularity.net>,
 Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 John David Anglin <dave.anglin@bell.net>, linux-parisc@vger.kernel.org,
 linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>,
 Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>
References: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
 <20190408095224.GA18914@techsingularity.net>
 <1554733749.3137.6.camel@HansenPartnership.com>
From: Helge Deller <deller@gmx.de>
Openpgp: preference=signencrypt
Autocrypt: addr=deller@gmx.de; keydata=
 xsBNBFDPIPYBCAC6PdtagIE06GASPWQJtfXiIzvpBaaNbAGgmd3Iv7x+3g039EV7/zJ1do/a
 y9jNEDn29j0/jyd0A9zMzWEmNO4JRwkMd5Z0h6APvlm2D8XhI94r/8stwroXOQ8yBpBcP0yX
 +sqRm2UXgoYWL0KEGbL4XwzpDCCapt+kmarND12oFj30M1xhTjuFe0hkhyNHkLe8g6MC0xNg
 KW3x7B74Rk829TTAtj03KP7oA+dqsp5hPlt/hZO0Lr0kSAxf3kxtaNA7+Z0LLiBqZ1nUerBh
 OdiCasCF82vQ4/y8rUaKotXqdhGwD76YZry9AQ9p6ccqKaYEzWis078Wsj7p0UtHoYDbABEB
 AAHNHEhlbGdlIERlbGxlciA8ZGVsbGVyQGdteC5kZT7CwJIEEwECADwCGwMGCwkIBwMCBhUI
 AgkKCwQWAgMBAh4BAheAFiEE9M/0wAvkPPtRU6Boh8nBUbUeOGQFAlrHzIICGQEACgkQh8nB
 UbUeOGT1GAgAt+EeoHB4DbAx+pZoGbBYp6ZY8L6211n8fSi7wiwgM5VppucJ+C+wILoPkqiU
 +ZHKlcWRbttER2oBUvKOt0+yDfAGcoZwHS0P+iO3HtxR81h3bosOCwek+TofDXl+TH/WSQJa
 iaitof6iiPZLygzUmmW+aLSSeIAHBunpBetRpFiep1e5zujCglKagsW78Pq0DnzbWugGe26A
 288JcK2W939bT1lZc22D9NhXXRHfX2QdDdrCQY7UsI6g/dAm1d2ldeFlGleqPMdaaQMcv5+E
 vDOur20qjTlenjnR/TFm9tA1zV+K7ePh+JfwKc6BSbELK4EHv8J8WQJjfTphakYLVM7ATQRQ
 zyD2AQgA2SJJapaLvCKdz83MHiTMbyk8yj2AHsuuXdmB30LzEQXjT3JEqj1mpvcEjXrX1B3h
 +0nLUHPI2Q4XWRazrzsseNMGYqfVIhLsK6zT3URPkEAp7R1JxoSiLoh4qOBdJH6AJHex4CWu
 UaSXX5HLqxKl1sq1tO8rq2+hFxY63zbWINvgT0FUEME27Uik9A5t8l9/dmF0CdxKdmrOvGMw
 T770cTt76xUryzM3fAyjtOEVEglkFtVQNM/BN/dnq4jDE5fikLLs8eaJwsWG9k9wQUMtmLpL
 gRXeFPRRK+IT48xuG8rK0g2NOD8aW5ThTkF4apznZe74M7OWr/VbuZbYW443QQARAQABwsBf
 BBgBAgAJBQJQzyD2AhsMAAoJEIfJwVG1HjhkNTgH/idWz2WjLE8DvTi7LvfybzvnXyx6rWUs
 91tXUdCzLuOtjqWVsqBtSaZynfhAjlbqRlrFZQ8i8jRyJY1IwqgvHP6PO9s+rIxKlfFQtqhl
 kR1KUdhNGtiI90sTpi4aeXVsOyG3572KV3dKeFe47ALU6xE5ZL5U2LGhgQkbjr44I3EhPWc/
 lJ/MgLOPkfIUgjRXt0ZcZEN6pAMPU95+u1N52hmqAOQZvyoyUOJFH1siBMAFRbhgWyv+YE2Y
 ZkAyVDL2WxAedQgD/YCCJ+16yXlGYGNAKlvp07SimS6vBEIXk/3h5Vq4Hwgg0Z8+FRGtYZyD
 KrhlU0uMP9QTB5WAUvxvGy8=
Message-ID: <1aca1299-8713-3d54-7c5e-adf791509987@gmx.de>
Date: Mon, 8 Apr 2019 17:22:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1554733749.3137.6.camel@HansenPartnership.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:kWlAezngvpfb2n7a1lRBUVONWArqVJncFVeLue2CvteOz7jUHPQ
 S34znCs4mDaKS3dXyBGZ46t2ugAej4trUil05EhTISZA/l9uECWwBMwipa3xsfj87lAk8tp
 EHy8nJt8UoSl7JdikQs7OgTEkq7z2ptvQH6TmIf+YiAAPc77Gpan/cZRWSeZWMD0cr8W/+o
 sSslSX3ITaUSq3JOqXbjA==
X-UI-Out-Filterresults: notjunk:1;V03:K0:nDFvRZFvgG0=:jlR1nLtIc6tBpGbNZY4F0w
 3jRWGQ4jrT8BKAKH8bSC7IdxSF3Hnt3MkBtu4v0nW3hfCMA+KlfuccV0qsnHXJ//2L3belptC
 DsbWTeBZrMejYknmauhsOuBX6kxzgZRAHeruWudKxI3NPg8RDQ9HMzrl52XSmkn+b2e/1aM2F
 yONZZ2S5xm9LTX7tO7nq9TDSVYiGHvOI7vim3jzyHSx6OM7D+ZglkZNrdGdlpdYUooHBqJmNf
 Soum8DH0+Q9yDbJmzPWu+NNRGjl7jkxVSzbG1B2obU2Cd3fjw6W1q7BL1ce+rgCPOuZMxoygP
 iDu0bbC44bEbyK89aBSM38njIAAAqnS1B+7hhWVcc7Ft47hqXRuYBfgozz9tUPE4LT1jQLCHH
 3b4U6Fsv0Xadkvq3jcRmksbot84KrSAfAlDnx/ehayFnZsZFGqR6KcOBlWvp7wKd7TMTibSmi
 w/QiZmUnYxiOooy3kOP31EPt2cfIPCrD4TMcoGNKIa8D7Y0X3T9YXeE4mpDA3DGehTbcSVqus
 5LZRIZzhkmyzodhsyEmKws8ojTTdvobd3XVlToLUhxFxIvwbEyokZESzQf+3tvPCFj5253HaB
 LUSAr3lu2JoPoo5ZtS/Jd++SWCgrOGzVXnNcgSWZR0Kj717kHc/FbacI4/RRHiJaU1j5rHb7v
 fJFfRk9vMUk93wpX5wkBViEq08DUpje0iEq1HE8dHYTyTIElDgS0pLASVzT1qZeJ7K+dkZHXC
 BAQCNBSeP5H/Pg5n3giFMpnz3kIAFGC2CAtCDV65Gu3YBtMCh7chCm+wh5TEEe43CYKTpN3bQ
 GlQ73dGPHlM0Sqh0TZdtpUX/pWolBrrG/ljQamozftpHciYLLb8FahWAHDPUaTZW1mLRM3oXp
 aARqxV9ZWATKqPd/WMSUUtwTij3ZXRDpUpYubP4f0bbammY/voEbfOaQ0lvrvL
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.04.19 16:29, James Bottomley wrote:
> On Mon, 2019-04-08 at 10:52 +0100, Mel Gorman wrote:
>> First, if pa-risc is !NUMA then why are separate local ranges
>> represented as separate nodes? Is it because of DISCONTIGMEM or
>> something else? DISCONTIGMEM is before my time so I'm not familiar
>> with it and I consider it "essentially dead" but the arch init code
>> seems to setup pgdats for each physical contiguous range so it's a
>> possibility. The most likely explanation is pa-risc does not have
>> hardware with addressing limitations smaller than the CPUs physical
>> address limits and it's possible to have more ranges than available
>> zones but clarification would be nice.
>
> Let me try, since I remember the ancient history.  In the early days,
> there had to be a single mem_map array covering all of physical memory.
>  Some pa-risc systems had huge gaps in the physical memory; I think one
> gap was somewhere around 1GB, so this lead us to wasting huge amounts
> of space in mem_map on non-existent memory.  What CONFIG_DISCONTIGMEM
> did was allow you to represent this discontinuity on a non-NUMA system
> using numa nodes, so we effectively got one node per discontiguous
> range.  It's hacky, but it worked.  I thought we finally got converted
> to sparsemem by the NUMA people, but I can't find the commit.

James, you tried once:
https://patchwork.kernel.org/patch/729441/

It seems we better should move over to sparsemem now?

Helge

