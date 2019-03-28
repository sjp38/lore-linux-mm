Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B837EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:34:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F3FE2075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:34:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="KIEVQmdN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F3FE2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFAD56B0003; Thu, 28 Mar 2019 19:34:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAAF06B0007; Thu, 28 Mar 2019 19:34:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4C026B0008; Thu, 28 Mar 2019 19:34:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 901BA6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:34:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id o67so131314pfa.20
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:34:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=a4JjKgKIVimDZFY8qHL1SLhhjDxQ2NbPDC8P33BMZJk=;
        b=EsCWRpu81H8fEqUb9gZyU0gsL/+J0EMZvIFo69HNB5CB2iD2AXBsAefcbJ/0nVSOdl
         yIy1n2DCP1xJOuRFBXaab/ky4LhOmdh6nRmi1scm4/M4KkUVys5Bw6FpPYvrMtTdMiU0
         RZbrxlwZwFtcebTpGDNKz/sTdpPNCWo6MMJkzHn14aMpf/rIIBzcvrs9lGm3BjF93Pwu
         Sq81DEmhFudTOpvs7sBOA6MbWDeLbqtOnkYmgEmj5R8daO5Efi338wcT16yUjlU16W3z
         Y4LKATz2TJwau+fHBcBZr6khGkbtYAw1tpCU0/5/h2BSEtIrnkcKBxYcCQSFkBNH/1a4
         ycbg==
X-Gm-Message-State: APjAAAWsXgC9aCkEgkZzwe4GIgtouG4urfKumDeXf0jqX9o0QPAd1MqF
	STRqmRjAyiJm516hW4UTuYTeBR1z0lcfz48ZdPsDL5tKzvvI6ymAf5lSBcORaNcMIJTrFJAtSar
	kUr+PuA+DsYyASrD4AqE/oENDfwEoONmaVXxKcupsSNbJpML1ftEbKQMNp78TNtnyQA==
X-Received: by 2002:a63:5659:: with SMTP id g25mr43036494pgm.436.1553816046241;
        Thu, 28 Mar 2019 16:34:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8eyNji9y4AeBsRpYwUCm5+SLIDgKjWqkwb4JtAa/HiluYdhy52zYdNf4JAoXRYgBwCXB1
X-Received: by 2002:a63:5659:: with SMTP id g25mr43036450pgm.436.1553816045509;
        Thu, 28 Mar 2019 16:34:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553816045; cv=none;
        d=google.com; s=arc-20160816;
        b=XkoVyJl/4ORJSpigXkHJm3GqsGqy2N2XwAScwtow5q/0iE53uYmQYKQG5nZM3AtQRN
         nrJ7Ouu+GwyZ8PEoxs1BFZfP2bAXw+kXoq7FJbe2rC811fJ1hSpw7KOf5OAl3dDVW7Rr
         wQkxU7foEjg7uRdsRphXAbOOMLyMy10RZoRraxW9lU1MrS8CPASQNRwswA6Z+JEJK2j8
         mKgMvQ72ZTT+kftY1JFhH1UeXySK4aUOXkETaqAUeNf7assgbEKnGHgKGvlfngNSpJDZ
         a+xaYpNhgKL+UUrsJ2ctQ6SpCpOtq4o6m9vKekm5mXJaRiYmZ7i75yg/NOZYNnq5wQ7B
         FuFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=a4JjKgKIVimDZFY8qHL1SLhhjDxQ2NbPDC8P33BMZJk=;
        b=D/T7tGT5yN74H8nq5Wz/dMKIJWwylKFEaoiIbxREaCRYbqvGBdcWk2Bmhykni+rUMX
         Y9drB1Vig0YnhCisn9h7vQAvsrgETFyEp0y9mY0UYSK82GMvUxBj7A4TnuJe5ZYkKEC+
         f4cEc/KRXu6tLN4kp3vAKMUsQi18N5rgLUXBgc8WsIZ388Ld+3gKl8rccb1IVV5INhF7
         qf2LfEuaOhdI9/QnyWWjqarxY4N5u6ZhhOd5OuATQCiLWx8IIj2C7JjFJiZy49BkLqSd
         pKeIWtOTGLS7X9PIZ1BZP257lskJmLzItFf6dKb5KjYru1oIrlTFWwJCGsfhOmBAQhcv
         MvZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KIEVQmdN;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id p1si400917pls.387.2019.03.28.16.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:34:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KIEVQmdN;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d59eb0000>; Thu, 28 Mar 2019 16:34:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 16:34:04 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 16:34:04 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 23:34:04 +0000
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-11-jglisse@redhat.com>
 <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
 <20190328213047.GB13560@redhat.com>
 <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
 <20190328220824.GE13560@redhat.com>
 <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
 <20190328224032.GH13560@redhat.com>
 <0b698b36-da17-434b-b8e7-4a91ac6c9d82@nvidia.com>
 <20190328230543.GI13560@redhat.com>
 <9e414b8c-0f98-a2f7-4f46-d335c015fc1b@nvidia.com>
 <20190328232404.GK13560@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <c02bcb34-bb3c-c3c9-f070-050006390776@nvidia.com>
Date: Thu, 28 Mar 2019 16:34:04 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328232404.GK13560@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553816043; bh=a4JjKgKIVimDZFY8qHL1SLhhjDxQ2NbPDC8P33BMZJk=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=KIEVQmdNnxSUaWWXtj4v6m//bq05m4Ae6TWF56k0Vg7ToGeYQyMfo0VWX77dUdH/B
	 99UJHRAfwWYzFT3kq+zomaSW9OBE4NJj0RxjVSESnJQRhuIapuCoeGyCQ8E8PBZTWp
	 xI8FWElX5ldyUScx1qHsAEy65QHcaOIkfyw8HwS35CEhwepVhr66Z3bj3eAYSN89Zw
	 V/XEHCZfiHteuHYZ9Jd3cYiJRbayCQVeXrFAhLDvRQoEQB5yVTJuK8pKL7vGuTVpGN
	 BLJu2uhNwhRHrVmusTKq9mtPftMxripQ0vJB6hA+A2KAMcaU2a9xwPCu+FeATEYLd2
	 jP36nbYD4ljDg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 4:24 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 04:20:37PM -0700, John Hubbard wrote:
>> On 3/28/19 4:05 PM, Jerome Glisse wrote:
>>> On Thu, Mar 28, 2019 at 03:43:33PM -0700, John Hubbard wrote:
>>>> On 3/28/19 3:40 PM, Jerome Glisse wrote:
>>>>> On Thu, Mar 28, 2019 at 03:25:39PM -0700, John Hubbard wrote:
>>>>>> On 3/28/19 3:08 PM, Jerome Glisse wrote:
>>>>>>> On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
>>>>>>>> On 3/28/19 2:30 PM, Jerome Glisse wrote:
>>>>>>>>> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
>>>>>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
>>>>>>>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>>>> [...]
>>>>>> OK, so let's either drop this patch, or if merge windows won't allow=
 that,
>>>>>> then *eventually* drop this patch. And instead, put in a hmm_sanity_=
check()
>>>>>> that does the same checks.
>>>>>
>>>>> RDMA depends on this, so does the nouveau patchset that convert to ne=
w API.
>>>>> So i do not see reason to drop this. They are user for this they are =
posted
>>>>> and i hope i explained properly the benefit.
>>>>>
>>>>> It is a common pattern. Yes it only save couple lines of code but dow=
n the
>>>>> road i will also help for people working on the mmap_sem patchset.
>>>>>
>>>>
>>>> It *adds* a couple of lines that are misleading, because they look lik=
e they
>>>> make things safer, but they don't actually do so.
>>>
>>> It is not about safety, sorry if it confused you but there is nothing a=
bout
>>> safety here, i can add a big fat comment that explains that there is no=
 safety
>>> here. The intention is to allow the page fault handler that potential h=
ave
>>> hundred of page fault queue up to abort as soon as it sees that it is p=
ointless
>>> to keep faulting on a dying process.
>>>
>>> Again if we race it is _fine_ nothing bad will happen, we are just doin=
g use-
>>> less work that gonna be thrown on the floor and we are just slowing dow=
n the
>>> process tear down.
>>>
>>
>> In addition to a comment, how about naming this thing to indicate the ab=
ove=20
>> intention?  I have a really hard time with this odd down_read() wrapper,=
 which
>> allows code to proceed without really getting a lock. It's just too wron=
g-looking.
>> If it were instead named:
>>
>> 	hmm_is_exiting()
>=20
> What about: hmm_lock_mmap_if_alive() ?
>=20

That's definitely better, but I want to vote for just doing a check, not=20
taking any locks.

I'm not super concerned about the exact name, but I really want a routine t=
hat
just checks (and optionally asserts, via WARN or BUG), and that's *all*. Th=
en
drivers can scatter that around like pixie dust as they see fit. Maybe righ=
t before
taking a lock, maybe in other places. Decoupled from locking.

thanks,
--=20
John Hubbard
NVIDIA

