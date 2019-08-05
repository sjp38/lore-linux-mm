Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95963C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:54:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BB592147A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:54:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="MABsVuv2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BB592147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 714C26B0003; Mon,  5 Aug 2019 18:54:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C4696B0006; Mon,  5 Aug 2019 18:54:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B44E6B0007; Mon,  5 Aug 2019 18:54:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 259E36B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 18:54:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 65so47069069plf.16
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 15:54:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=su7Un7Lsr0IB37YVHfSyk5WWru26t8lLPZpTgkOrxAY=;
        b=oEvkY1M8NQxSqFzJryw5IWnplmpsbtwkAb1xYyWGTDq6EiP4auxD4IqHR7iPpijNri
         ZwLOn1G7GbN+bFIK/jPLA4yOBehgwYP6jVtN0UfFySO2uSZY+n4u42VZApwmZd3BRvoh
         ErWhKU4z6KffQxvvzb2ebga0C0O1v2oknTNivgydfqCapEW9vPJXwyhsD9PhX7GkjZ/B
         L37VYZ3akMdVnEDJbOGIPx8Mkw5W0IOm/eqkMUpkTTUdzAgqucdBgXr04a2Hm3jjnBjR
         E5YU6tyM4uE40bZFOGFl/3hu66e7yJ4aD1+96WwuP0LgIiow84C2aFrpSkXGRlu2y6AI
         MqFw==
X-Gm-Message-State: APjAAAX7eJqZU2R4ZZEFeWlxbatzO65bwVN1J7LC62dV44wDLveIy5Fn
	ALxuN1uWLMSWt+U4qYDIj/9j8kDMtKcBviqVF2U/DPjluHLiPxPMbTOxZbtra9tTTPN6K2EkJMJ
	Nz5oWGR9vEqHp4OrxKkFcgfTDke9/12U55BoR+/YtmDCIesFii4iBL7qd5ok06hjUyQ==
X-Received: by 2002:a17:902:41:: with SMTP id 59mr113074pla.195.1565045677693;
        Mon, 05 Aug 2019 15:54:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQ2ZzwsOUnvPvsp4+o/ZdBCaBKyuyHVb+l9urE1/lFaeVFbbvDZkTRfBymjS2St63LGzSu
X-Received: by 2002:a17:902:41:: with SMTP id 59mr113038pla.195.1565045676747;
        Mon, 05 Aug 2019 15:54:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565045676; cv=none;
        d=google.com; s=arc-20160816;
        b=eSqqjht1sH9DDb5P4yMJO1BsESnkGTIrXQ6jtOZQvSKxtImQxycBE5FEjK72gilq9F
         dYCYxPsL54GJfscUOP2AX0w69mwcazba3dG3zf1FcTaN3kvQFAKoke0+m1W0JhTe7SyZ
         IfgQZdgTUU7Zn+y8AwnlHPc9HBTXCi2/QP63IsWH3hV9NqiA2rwdv8ni6SFu0EmKSF5j
         VSCJCzEdA2GIna2owT74vI6o7cZ99+JFEPX2yrX4IuMznBjBv1iDeT4U48Yj+beOZjo1
         Xi+9on17OgdHClir4GBLBZvk8JhlHzBAJebwVlsVq7ghXNClJgvz5qm4SGDPnoEeDECo
         7fMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=su7Un7Lsr0IB37YVHfSyk5WWru26t8lLPZpTgkOrxAY=;
        b=Cws+Y1pmkOfJVwOWwYsvCXCrnUIbFurELriFHNUpi1vA1lP6Yrue71Hz2cRDujkWJt
         Kefdkom7++pxTCXkNaHlQQ3lnQXP1RtSpjwoUItgW+u0D9zo2KD4TcyEbCMH63Np62L0
         O1k4VzQsk3rPpJzcBFhaQkguQ99Zer6nhWyqu+CiIYhUojRmu94O87Ig/PPIOQkOhb21
         lZhtpCO1X4Kb4xZT99fbWBU6BnUQYc4sj7VyVvhl6jBfxc00RhUvkZtVSALxQySp5IjT
         FpUfvYt4d3OToBWl8Rb8PzSisq5Vje3stt8uTlmmr6loCCiOsL4Jg9HGkkT7ByOUjX3O
         phqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=MABsVuv2;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id l36si19166756pgb.292.2019.08.05.15.54.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 15:54:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=MABsVuv2;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d48b3b50000>; Mon, 05 Aug 2019 15:54:45 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 05 Aug 2019 15:54:36 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 05 Aug 2019 15:54:36 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 5 Aug
 2019 22:54:35 +0000
Subject: Re: [PATCH 00/12] block/bio, fs: convert put_page() to
 put_user_page*()
To: Christoph Hellwig <hch@infradead.org>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro
	<viro@zeniv.linux.org.uk>, Anna Schumaker <anna.schumaker@netapp.com>, "David
 S . Miller" <davem@davemloft.net>, Dominique Martinet
	<asmadeus@codewreck.org>, Eric Van Hensbergen <ericvh@gmail.com>, Jason
 Gunthorpe <jgg@ziepe.ca>, Jason Wang <jasowang@redhat.com>, Jens Axboe
	<axboe@kernel.dk>, Latchesar Ionkov <lucho@ionkov.net>, "Michael S . Tsirkin"
	<mst@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>, Trond Myklebust
	<trond.myklebust@hammerspace.com>, Christoph Hellwig <hch@lst.de>, Matthew
 Wilcox <willy@infradead.org>, <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>, <ceph-devel@vger.kernel.org>,
	<kvm@vger.kernel.org>, <linux-block@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>, <samba-technical@lists.samba.org>,
	<v9fs-developer@lists.sourceforge.net>,
	<virtualization@lists.linux-foundation.org>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
 <20190724061750.GA19397@infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <c35aa2bf-c830-9e57-78ca-9ce6fb6cb53b@nvidia.com>
Date: Mon, 5 Aug 2019 15:54:35 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724061750.GA19397@infradead.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565045686; bh=su7Un7Lsr0IB37YVHfSyk5WWru26t8lLPZpTgkOrxAY=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=MABsVuv2G9BzGpy+DkzIhxi90zmgNTMYOagd/ashPLcDOi2sWU6YznkbyPDv/xcq/
	 O5RFeXAwmCAh/JO0LO+ze2NEhPe2n+psweVYXa8pjERXCCCfGYTxQ9SDkc4s4KNR59
	 NLyb52q+/1fN+RE5h7a69JZCsNpaL7gcHJobrCC7E9UqWrmG9ACN7VwIX7DKaTA/Rb
	 eRaFep1AoazjTxyXxT6Tx1JQhDVjP38m4xzwGlHYvs4ZQCYA68yceeG7xda5nxeUcP
	 Q7wlfmFbcUA/T+jBVHNbqmQyCuHaQMhgKiqtQK78vKYLrwPUcmbghr4B0X7IdrZjfb
	 e4QZrUIdtNMcg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 11:17 PM, Christoph Hellwig wrote:
> On Tue, Jul 23, 2019 at 09:25:06PM -0700, john.hubbard@gmail.com wrote:
>> * Store, in the iov_iter, a "came from gup (get_user_pages)" parameter.
>>   Then, use the new iov_iter_get_pages_use_gup() to retrieve it when
>>   it is time to release the pages. That allows choosing between put_page=
()
>>   and put_user_page*().
>>
>> * Pass in one more piece of information to bio_release_pages: a "from_gu=
p"
>>   parameter. Similar use as above.
>>
>> * Change the block layer, and several file systems, to use
>>   put_user_page*().
>=20
> I think we can do this in a simple and better way.  We have 5 ITER_*
> types.  Of those ITER_DISCARD as the name suggests never uses pages, so
> we can skip handling it.  ITER_PIPE is rejected =D1=96n the direct I/O pa=
th,
> which leaves us with three.
>=20

Hi Christoph,

Are you working on anything like this? Or on the put_user_bvec() idea?
Please let me know, otherwise I'll go in and implement something here.


thanks,
--=20
John Hubbard
NVIDIA

> Out of those ITER_BVEC needs a user page reference, so we want to call
> put_user_page* on it.  ITER_BVEC always already has page reference,
> which means in the block direct I/O path path we alread don't take
> a page reference.  We should extent that handling to all other calls
> of iov_iter_get_pages / iov_iter_get_pages_alloc.  I think we should
> just reject ITER_KVEC for direct I/O as well as we have no users and
> it is rather pointless.  Alternatively if we see a use for it the
> callers should always have a life page reference anyway (or might
> be on kmalloc memory), so we really should not take a reference either.
>=20
> In other words:  the only time we should ever have to put a page in
> this patch is when they are user pages.  We'll need to clean up
> various bits of code for that, but that can be done gradually before
> even getting to the actual put_user_pages conversion.
>=20

