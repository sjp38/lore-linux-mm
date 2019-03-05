Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B391C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 00:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E071C206B8
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 00:05:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E071C206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 706038E0003; Mon,  4 Mar 2019 19:05:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B5568E0001; Mon,  4 Mar 2019 19:05:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57EA88E0003; Mon,  4 Mar 2019 19:05:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 260D38E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 19:05:30 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id p131so291649oif.8
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 16:05:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=CbM9gHvG4wMm1LFqcYuYdGuMeLonmorIIzq+hI7EJ9s=;
        b=p2zQPQHvHvsJ16/yyeFKpKYC9gj8jgEE3Gr0vnAPRboChFbseqV+P4HbPO/Z8ADf71
         UdttigLy8FQGhD1zqhANknEU3VhfStJm+33BhPyq54ilfeB8Mv4m+cjx4L9gYWhPGtiR
         AurQF42rK/r3imTJe8KPD1QXalo4Zq4huOvhuOhGqmN/+reh4/Rj9lPP47wPab3YCq6i
         yuDZvcb5FBBRHkIpBnBOpazKz8VXhm3MXxPHHDmJGvAuMMSiQVFQJ2rYadtZwiTZMNvO
         yr7Ppk3YJguvIQ6rZx6me3//C/IWebohX/OGR0z8C4T6yu+D6efS0F38QtUNjfYQil+c
         ktpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAU/CSM4YTTUtRP+NB2/3s3dmfRZaMMgE25RAHpyooFfOkWWatDC
	SdW3SfaMaxx45idlLjBegnf3Rp+QwL3Ido6lmcN4Wi/UU7/1f/Rayyyltnr4juLCRlqY4HJABWq
	fA2OU1q9dowe/XuyoiebHHbI/IMwbw4pb2opNtK8y3xD5RKVgn8kKNMJs1I0N7vSk4A==
X-Received: by 2002:a9d:76c5:: with SMTP id p5mr14457935otl.283.1551744329826;
        Mon, 04 Mar 2019 16:05:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqyfzm3QYVoRBrcu63M7rh5zgHgMg12NQkGSxP85GktZf6JtXjMzUaj8DaBfGhibenI5MBnu
X-Received: by 2002:a9d:76c5:: with SMTP id p5mr14457875otl.283.1551744328778;
        Mon, 04 Mar 2019 16:05:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551744328; cv=none;
        d=google.com; s=arc-20160816;
        b=hVf6jLFkKfJ5sXzetDjRIWnw8s+Sbh0tay0Y0HKgClQ5poLoNqp28VTzZ1Ilch+l7S
         wFhu7eJkZUI/P+tY3LDHzOxhKOKzJQKUu3WcTavy6ECh+vkm5AgyPZx9h1L1oU2PiFPA
         OfS6x2yqjZKLzUi2+VtI4hVAOeL0KA57vx/PR64nDOlfZVLMmX0NFSC1RG/JKwawKaW7
         1RiorCrG6FRgUogCoxMVW7Ogeo5aenECBpNrJlUuThKISg9Yu7eO8K2MxhqO6Zl3EGC+
         y21bfKXnpgIkM8p1qb3MnTCkpa1sFiBGXJdYMVRAzNQ3xDIx8SWcsh6nxBMWvBGVf7bH
         KwkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=CbM9gHvG4wMm1LFqcYuYdGuMeLonmorIIzq+hI7EJ9s=;
        b=jx2QFPcwrEQa6ysKhTpqZXVIwP9ckiMOxwUm0/e+ZEbErOY+8WnEYISMCzJH3HfaIw
         bfEqm2O/0hXEMQJsu7c8kbA66a91qMR8P1Ql5XGCvFSRxHSNpi8NOdf2+yQZa9W+pe2v
         PLgkVB2hTLoN9C+uT8u0+GSOL/+bfJTgUfFDWGLgNNf58bO2lAyWOOd5xRS21L94gy4m
         8C6qogDaC4gDBIgE9uSD/FJUhNbwuCMx3jzqA85YuA3tmWUP5fD8uXC/fDZNpmcKftkA
         pS4qFSESQZKpTYGKZntbniMqowKH6AE6w39kVPg1UThP1dvyVfoJ6I1bQLV96ckZapDE
         0DnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id l13si3105994otp.220.2019.03.04.16.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 16:05:28 -0800 (PST)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x2505DvQ001559
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 5 Mar 2019 09:05:13 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2505D98029259;
	Tue, 5 Mar 2019 09:05:13 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2504r7K005945;
	Tue, 5 Mar 2019 09:05:13 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.149] [10.38.151.149]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-3007610; Tue, 5 Mar 2019 09:04:01 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC21GP.gisp.nec.co.jp ([10.38.151.149]) with mapi id 14.03.0319.002; Tue, 5
 Mar 2019 09:04:00 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        David Rientjes <rientjes@google.com>,
        Jing Xiangfeng <jingxiangfeng@huawei.com>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "hughd@google.com" <hughd@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "Andrea Arcangeli" <aarcange@redhat.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
Thread-Topic: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
Thread-Index: AQHUzKNmJ08QFadITkadXECqBzMSPaXvQTOAgADisACAABkvAIAAEDUAgAB2wwCAAEK9AIAA3REAgAAzZACAABhSgIAJbiwA
Date: Tue, 5 Mar 2019 00:03:59 +0000
Message-ID: <20190305000402.GA4698@hori.linux.bs1.fc.nec.co.jp>
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
In-Reply-To: <086c4a4b-a37d-f144-00c0-d9a4062cc5fe@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <853429AEAD48A04F86B60F723266BFD0@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 04:03:23PM -0800, Mike Kravetz wrote:
> On 2/26/19 2:36 PM, Andrew Morton wrote:
...
> >>
> >> +	} else {
> >>  		/*
> >> -		 * per node hstate attribute: adjust count to global,
> >> -		 * but restrict alloc/free to the specified node.
> >> +		 * Node specific request, but we could not allocate
> >> +		 * node mask.  Pass in ALL nodes, and clear nid.
> >>  		 */
> >=20
> > Ditto here, somewhat.

# I missed this part when reviewing yesterday for some reason, sorry.

>=20
> I was just going to update the comments and send you a new patch, but
> but your comment got me thinking about this situation.  I did not really
> change the way this code operates.  As a reminder, the original code is l=
ike:
>=20
> NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
>=20
> if (nid =3D=3D NUMA_NO_NODE) {
> 	/* do something */
> } else if (nodes_allowed) {
> 	/* do something else */
> } else {
> 	nodes_allowed =3D &node_states[N_MEMORY];
> }
>=20
> So, the only way we get to that final else if if we can not allocate
> a node mask (kmalloc a few words).  Right?  I wonder why we should
> even try to continue in this case.  Why not just return right there?

Simply returning on allocation failure looks better to me.
As you mentioned below, current behavior for this 'else' case is not
helpful for anyone.

Thanks,
Naoya Horiguchi

>=20
> The specified count value is either a request to increase number of
> huge pages or decrease.  If we can't allocate a few words, we certainly
> are not going to find memory to create huge pages.  There 'might' be
> surplus pages which can be converted to permanent pages.  But remember
> this is a 'node specific' request and we can't allocate a mask to pass
> down to the conversion routines.  So, chances are good we would operate
> on the wrong node.  The same goes for a request to 'free' huge pages.
> Since, we can't allocate a node mask we are likely to free them from
> the wrong node.
>=20
> Unless my reasoning above is incorrect, I think that final else block
> in __nr_hugepages_store_common() is wrong.
>=20
> Any additional thoughts?
> --=20
> Mike Kravetz
> =

