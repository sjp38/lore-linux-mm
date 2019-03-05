Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CA2DC43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:42:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B89D20675
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:42:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B89D20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC60D8E0003; Tue,  5 Mar 2019 16:42:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4D7C8E0001; Tue,  5 Mar 2019 16:42:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EE738E0003; Tue,  5 Mar 2019 16:42:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 411EF8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 16:42:01 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k21so5237725eds.19
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 13:42:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=Bwz5i5J4w6R1JZ8oshOTubR9szUXAlwoXGZPPZY1maE=;
        b=q2tpcM+6S3mVCTcg0EYIkdasSjXlCheD5t+P3s8LsphP5NigQlkXIwqWCVaGLmmEl/
         kRBl5qR03rJR3/ZOnz71qNosfhuV4QAf0icwtbN2nqF122q5T2J9CVu/+9uRwNqQ+oB9
         FjIXo2gMxYy+hLg1Ag5fRuZzY28k6Cudv4mHSL+zcT1Qv6ZZj5QtRDf8rXnivB84JM1p
         gUCGzJEYazjT42HFtE/P2aQNQoZrlSmk8mbQ/K0Cr69GrvD+c5VxznLxbuDX1frqOfd3
         MeRKNn46VWVb1nsEWlwgjGoW4peoRRH65mgQlXtpDJOKKVd9ezWMAJTpC5Gbc9s8UQMH
         RDPw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUZOvnTiwH3Kl/SUzWl1Qqs5WhVTRHZaQzspaZ0B5ZqA6WdOumF
	gKy7Dv0dYeYQahGtOUqeaxFGU7XONpg79E6Obu2RQXdZviCnQ0qO21nrbNMfUVi6D8vUXR5w23+
	cpP3KbuAbM20A/hOpDCyQZ7Cfbyrgh+B5vrYTYZgG13B8Oev7u3qBUtEkEWBj1aE=
X-Received: by 2002:a17:906:4212:: with SMTP id z18mr1652627ejk.78.1551822120846;
        Tue, 05 Mar 2019 13:42:00 -0800 (PST)
X-Google-Smtp-Source: APXvYqw9OEbYbY++jj+37j4jpGpCYpebjtw/5YcLRkSUa/HgRbPaUMsdALTZpf9PX3TluIEvQt+H
X-Received: by 2002:a17:906:4212:: with SMTP id z18mr1652596ejk.78.1551822120003;
        Tue, 05 Mar 2019 13:42:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551822119; cv=none;
        d=google.com; s=arc-20160816;
        b=z6vcQDpu2yELrBAfj0EQIvo+1e/yD77Gqvnhqu+jbIxqa7C5mrB9WzXuQu9X4yS3E3
         tJN7A70PLJvLsagguu0PQqndrveT+8Dlg/+uk7t5Pdii1pglPwvOk2YXb5Ta21YsDGLn
         3u325zf2gW8VODAyvMCD/rbkmaGl0INZkop2EQiGtG+Af21f0VDs7WkCsolGxpccRdfE
         HYkNDCWZWhLyG8HICO+VoFC0pz1Z03YdzN8Puo5+c1tajQED1im7uTcBGQFxHJ+kZP9C
         Qb2+xQliBzwFwRYgr9YaJoWWjM/uBYzjfq/PkQw0mZ+yAYcyLO5ZWW/4Z3jTPPcWk1C0
         0tDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:references:subject:cc:to:from;
        bh=Bwz5i5J4w6R1JZ8oshOTubR9szUXAlwoXGZPPZY1maE=;
        b=vdzgqX7qhktT4VW3VRb+jFMV4nFfHqSgUJexBsM6zeszb4Xr7P4QrAsqIkLlAySTXF
         B9d45tVqrys/I8NkMxVhP5zPThkSspkVA51Q1ecHMqm4ZPqFv3JEmXTu5E4oTLtewZz0
         A4wyukuBe3Lg9pnQsMuEjxylxDv0/rBS8RrJbqBc0A2hblb/KJHsBwGmk6k6GsQh0MGc
         BpW9M0pfrxtDp2JHGpCOzwzrADLH8Lejvpw0Tqz+hkP8uEuWHg25UrVcpLKxq/AY9Uvj
         k0QvNWhuLBw+S5L6UCR0o9TnG48owtweo7SsKqYqnOv+VVwPe6hmSBJX+56LyEZOv7aU
         w/QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id f19si703137edf.175.2019.03.05.13.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Mar 2019 13:41:59 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 49734FF804;
	Tue,  5 Mar 2019 21:41:56 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Oscar Salvador <osalvador@suse.de>, David Rientjes <rientjes@google.com>,
 Jing Xiangfeng <jingxiangfeng@huawei.com>,
 "mhocko@kernel.org" <mhocko@kernel.org>, "hughd@google.com"
 <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Andrea Arcangeli <aarcange@redhat.com>,
 "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
 linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
References: <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
 <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
 <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
 <5C74A2DA.1030304@huawei.com>
 <alpine.DEB.2.21.1902252220310.40851@chino.kir.corp.google.com>
 <e2bded2f-40ca-c308-5525-0a21777ed221@oracle.com>
 <20190226143620.c6af15c7c897d3362b191e36@linux-foundation.org>
 <086c4a4b-a37d-f144-00c0-d9a4062cc5fe@oracle.com>
 <20190305000402.GA4698@hori.linux.bs1.fc.nec.co.jp>
 <8f3aede3-c07e-ac15-1577-7667e5b70d2f@oracle.com>
 <20190305131643.94aa32165fecdb53a1109028@linux-foundation.org>
 <9a23edc9-b2e5-839e-30d6-0723cb98246d@oracle.com>
Message-ID: <8d77e5ba-3de6-801c-8497-6a219665bc57@ghiti.fr>
Date: Tue, 5 Mar 2019 16:41:55 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <9a23edc9-b2e5-839e-30d6-0723cb98246d@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/5/19 4:35 PM, Mike Kravetz wrote:
> On 3/5/19 1:16 PM, Andrew Morton wrote:
>> On Mon, 4 Mar 2019 20:15:40 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>
>>> Andrew, this is on top of Alexandre Ghiti's "hugetlb: allow to free gigantic
>>> pages regardless of the configuration" patch.  Both patches modify
>>> __nr_hugepages_store_common().  Alex's patch is going to change slightly
>>> in this area.
>> OK, thanks, I missed that.  Are the changes significant?
>>
> No, changes should be minor.  IIRC, just checking for a condition in an
> error path.
I will send the v5 of this patch tomorrow, I was waiting for architecture
maintainer remarks. I still miss sh, but I'm confident on this change.

Alex

