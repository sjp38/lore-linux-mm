Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 793F2C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:04:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 475FE20651
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:04:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 475FE20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=daenzer.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE47B6B000A; Tue, 16 Jul 2019 13:04:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D950D8E0003; Tue, 16 Jul 2019 13:04:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5E9F6B000E; Tue, 16 Jul 2019 13:04:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 731556B000A
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:04:56 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id l24so10819693wrb.0
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:04:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=rPDgsQ3kgUM6wlTwcnBLC4OEpnhq1V0baGEEr/olLNk=;
        b=qTPu92RDf0TOuJDVTqYLXdeuTmvELUPVPWHIqkfOL9NHjXx7qMGp/KXSe0BoX/yKVl
         bp0+8PzszSeyVRa0hcyPS2jNlgoUnN3Wiq64aPL5V/Ef+H+YAf8951NlUio5li0hTk8e
         zy1StIceWh4lyRF3lbCgC4/auLeQ5WviW1BbB+jce3TKRizxePD44ilfwrH+ppPF3La0
         okNcvMw3yVUjOfz6P5KTxbmmYKiiaIi0qa4cyM/K4fIUwXSO+D4fQulsNoVp1GWFl3em
         7Ji5SgQt8ju5MckSey4iEFCocDpIt4/bgrglwh8e85IVYMABAmoBthvIaCRmQy+IwN9q
         BKAw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
X-Gm-Message-State: APjAAAWYB8hQFnRAglgGfzhkg+kKM4bzAfoAlcVmuSj6fNhPKr8Wf6k/
	0FAW4/kER0df31GLWdy37JnQ7+HJAYeCELzGC1MKFvlrTOH5P51iM9Q2CVxd5hBqEDBqDsH4TAt
	Q06lHgDPcWPgV7ZhUVYi/FKgHIb57i+NyrhG/GdA2o9QAB8PIuME6nJ+Bk6yKd/M=
X-Received: by 2002:adf:ef49:: with SMTP id c9mr38420848wrp.188.1563296695977;
        Tue, 16 Jul 2019 10:04:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxXHCWS2onVCDdGMwT9OqxyW8s+0YF32Hn2kfmDVu06HYxiVI9uEf1nQ9ZC2AI62e2csBu
X-Received: by 2002:adf:ef49:: with SMTP id c9mr38420786wrp.188.1563296694977;
        Tue, 16 Jul 2019 10:04:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563296694; cv=none;
        d=google.com; s=arc-20160816;
        b=Tge53rMCaYAf8erljYo+Pg3AsOAsR6vNljiWdHbXQgEAtxbSMfkbNoFf4IH5XzPNuY
         dSe6n/e1r+C6tPZDqH7aU8DnNo5iIbczfMKgJzLg0+jEviA0j8suudskDKNIElGtLg4g
         r1hEFw2rtK2Gq3PAGRbPPrhwWoRAbmVOiciPPD52Xy7t/MMjABaBmLKgCM5fWc+rg+1i
         ULrb0H/f4KsDOqKIcz5kkOQt2p0TknsV4bw+JYlqQbKfipvYEWorYNBiw6IGSc8VjFB7
         wPHisJq6+kZ3kng74RdsufTRMGTU8KT09ANR2MCdA8l2lQP8dgly00xVSElUoBJ7rXFJ
         whRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=rPDgsQ3kgUM6wlTwcnBLC4OEpnhq1V0baGEEr/olLNk=;
        b=wvr97IusEnGgqjy26v9oMYgeoa/1rcuZLK+tU16yOfTAIgY5JynfUUSigPKMvXdDKq
         eM+pmsSXBajpjmHTyzZ9anTRPH2Tqx7dAAJgET/GmBZRRnp6WDi4Lp+9NgZFeryyyVz3
         PL21Dxn0I0GiBCZL0e0fYGw3wNdAbwd60Tdhg9Le92WHbg0xqdNkJVHSoeI1jSHxY2Mv
         swGsVJWSoqqHofNKgslLH6Fn98O2Tftj8wlAQ+TAwswNRqTrjfbLofhJHUZrBZjOa9bS
         Yw4BgLYHzUH4TI6JC47W7hK614hjmr2DeE+avGJ5pQbxLmRpvf4dy86Glfe5j5wriIxj
         H9fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id r11si20225815wrn.103.2019.07.16.10.04.54
        for <linux-mm@kvack.org>;
        Tue, 16 Jul 2019 10:04:54 -0700 (PDT)
Received-SPF: neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) client-ip=148.251.143.178;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from localhost (localhost [127.0.0.1])
	by netline-mail3.netline.ch (Postfix) with ESMTP id 693AC2AA12C;
	Tue, 16 Jul 2019 19:04:54 +0200 (CEST)
X-Virus-Scanned: Debian amavisd-new at netline-mail3.netline.ch
Received: from netline-mail3.netline.ch ([127.0.0.1])
	by localhost (netline-mail3.netline.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id NJeX02vqF-eQ; Tue, 16 Jul 2019 19:04:53 +0200 (CEST)
Received: from thor (116.245.63.188.dynamic.wline.res.cust.swisscom.ch [188.63.245.116])
	by netline-mail3.netline.ch (Postfix) with ESMTPSA id BB70E2AA0E9;
	Tue, 16 Jul 2019 19:04:53 +0200 (CEST)
Received: from localhost ([::1])
	by thor with esmtp (Exim 4.92)
	(envelope-from <michel@daenzer.net>)
	id 1hnQsn-0007gH-EB; Tue, 16 Jul 2019 19:04:53 +0200
Subject: Re: HMM related use-after-free with amdgpu
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
References: <9a38f48b-3974-a238-5987-5251c1343f6b@daenzer.net>
 <20190715172515.GA5043@mellanox.com>
 <823db68e-6601-bb3a-0c1f-bfc5169cb7c9@daenzer.net>
 <20190716163545.GF29741@mellanox.com>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Openpgp: preference=signencrypt
Autocrypt: addr=michel@daenzer.net; prefer-encrypt=mutual; keydata=
 mQGiBDsehS8RBACbsIQEX31aYSIuEKxEnEX82ezMR8z3LG8ktv1KjyNErUX9Pt7AUC7W3W0b
 LUhu8Le8S2va6hi7GfSAifl0ih3k6Bv1Itzgnd+7ZmSrvCN8yGJaHNQfAevAuEboIb+MaVHo
 9EMJj4ikOcRZCmQWw7evu/D9uQdtkCnRY9iJiAGxbwCguBHtpoGMxDOINCr5UU6qt+m4O+UD
 /355ohBBzzyh49lTj0kTFKr0Ozd20G2FbcqHgfFL1dc1MPyigej2gLga2osu2QY0ObvAGkOu
 WBi3LTY8Zs8uqFGDC4ZAwMPoFy3yzu3ne6T7d/68rJil0QcdQjzzHi6ekqHuhst4a+/+D23h
 Za8MJBEcdOhRhsaDVGAJSFEQB1qLBACOs0xN+XblejO35gsDSVVk8s+FUUw3TSWJBfZa3Imp
 V2U2tBO4qck+wqbHNfdnU/crrsHahjzBjvk8Up7VoY8oT+z03sal2vXEonS279xN2B92Tttr
 AgwosujguFO/7tvzymWC76rDEwue8TsADE11ErjwaBTs8ZXfnN/uAANgPLQjTWljaGVsIERh
 ZW56ZXIgPG1pY2hlbEBkYWVuemVyLm5ldD6IXgQTEQIAHgUCQFXxJgIbAwYLCQgHAwIDFQID
 AxYCAQIeAQIXgAAKCRBaga+OatuyAIrPAJ9ykonXI3oQcX83N2qzCEStLNW47gCeLWm/QiPY
 jqtGUnnSbyuTQfIySkK5AQ0EOx6FRRAEAJZkcvklPwJCgNiw37p0GShKmFGGqf/a3xZZEpjI
 qNxzshFRFneZze4f5LhzbX1/vIm5+ZXsEWympJfZzyCmYPw86QcFxyZflkAxHx9LeD+89Elx
 bw6wT0CcLvSv8ROfU1m8YhGbV6g2zWyLD0/naQGVb8e4FhVKGNY2EEbHgFBrAAMGA/0VktFO
 CxFBdzLQ17RCTwCJ3xpyP4qsLJH0yCoA26rH2zE2RzByhrTFTYZzbFEid3ddGiHOBEL+bO+2
 GNtfiYKmbTkj1tMZJ8L6huKONaVrASFzLvZa2dlc2zja9ZSksKmge5BOTKWgbyepEc5qxSju
 YsYrX5xfLgTZC5abhhztpYhGBBgRAgAGBQI7HoVFAAoJEFqBr45q27IAlscAn2Ufk2d6/3p4
 Cuyz/NX7KpL2dQ8WAJ9UD5JEakhfofed8PSqOM7jOO3LCA==
Message-ID: <cc010b8d-0018-783a-648f-01099fc63352@daenzer.net>
Date: Tue, 16 Jul 2019 19:04:52 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190716163545.GF29741@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-16 6:35 p.m., Jason Gunthorpe wrote:
> On Tue, Jul 16, 2019 at 06:31:09PM +0200, Michel Dänzer wrote:
>> On 2019-07-15 7:25 p.m., Jason Gunthorpe wrote:
>>> On Mon, Jul 15, 2019 at 06:51:06PM +0200, Michel Dänzer wrote:
>>>>
>>>> With a KASAN enabled kernel built from amd-staging-drm-next, the
>>>> attached use-after-free is pretty reliably detected during a piglit gpu run.
>>>
>>> Does this branch you are testing have the hmm.git merged? I think from
>>> the name it does not?
>>
>> Indeed, no.
>>
>>
>>> Use after free's of this nature were something that was fixed in
>>> hmm.git..
>>>
>>> I don't see an obvious way you can hit something like this with the
>>> new code arrangement..
>>
>> I tried merging the hmm-devmem-cleanup.4 changes[0] into my 5.2.y +
>> drm-next for 5.3 kernel. While the result didn't hit the problem, all
>> GL_AMD_pinned_memory piglit tests failed, so I suspect the problem was
>> simply avoided by not actually hitting the HMM related functionality.
>>
>> It's possible that I made a mistake in merging the changes, or that I
>> missed some other required changes. But it's also possible that the HMM
>> changes broke the corresponding user-pointer functionality in amdgpu.
> 
> Not sure, this was all Tested by the AMD team so it should work, I
> hope.

It can't, due to the issue pointed out by Linus in the "drm pull for
5.3-rc1" thread: DRM_AMDGPU_USERPTR still depends on ARCH_HAS_HMM, which
no longer exists, so it can't be enabled.

Fixing that up manually, it successfully finished a piglit run with that
functionality enabled as well.


-- 
Earthling Michel Dänzer               |              https://www.amd.com
Libre software enthusiast             |             Mesa and X developer

