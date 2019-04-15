Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F50EC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 06:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09D032073F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 06:18:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09D032073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49CA46B0007; Mon, 15 Apr 2019 02:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4233E6B0008; Mon, 15 Apr 2019 02:18:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C6E86B000A; Mon, 15 Apr 2019 02:18:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E404B6B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 02:18:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c7so10719330plo.8
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 23:18:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Ul5rn3TEwoKFWJAM7LDQzFG0ycKQ5Z8xC5TsjVChqI0=;
        b=JPZao8xZFT2V7ap/V5EmJcmTa+RsyhwR0o/ypyl95TtlB4EHT9d/h2aoScgKosw1I0
         tb79B4vSolQLWiYmJ/V4IWo9gIBbIZHTgvs3sULq/5cRGw2FbBU2VGV3xNcUTKVyH3h5
         hTSeixiqoOcbbmB2bJKc5/EZsYEkAthysG7XceVwZclJbZXTSQuKpgEblniR5iLaFatc
         VQQ4QuaZpZGAIM8ChzZNvWX+qk9m+bHH1//OU7va3S3p6hXJklgESidmvbD42TSci/Pi
         i+X/8VjoxN1dz6a6kAPAdRpzosIxW4fbmqCMH/ozeaLp/Oe0cCRdFIt34/zee4+vL8Gd
         bgaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAUFry/2XdnluanzBzujPu24G5q87oCFPNI3o5n5i5Gl/HlrzxkY
	am8aawEeznQjxI5ej55+NN9pRP2RaVlxUVN6JALiUg3XssQX5GvdIkcAkJNfRdk1lQRqtlaYbgb
	EOzm+67sXxD+fxqac7gARff9CDE+ZUvmt0uWkGaPH6NHZJhDp6v5fVHL4fuH7MKi1ZQ==
X-Received: by 2002:a63:4616:: with SMTP id t22mr68831217pga.217.1555309088482;
        Sun, 14 Apr 2019 23:18:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/lrMUstMDzlHEY0Hed3wb14fbboFJZORkFMx85xH3MGy0F8ys78ib9yfm4W5tur3kY1AB
X-Received: by 2002:a63:4616:: with SMTP id t22mr68831156pga.217.1555309087382;
        Sun, 14 Apr 2019 23:18:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555309087; cv=none;
        d=google.com; s=arc-20160816;
        b=usgXPp/VkYFDboRfjyOJk1Ru9LY10oz3SVmqXByLiRvFT1zDkBI/dXajU6eQtu7Wsd
         CGahsAZy6jQkVj0G6Vmn3+1iUWah27ekKV3Gbwotmp8V/0J7Z6lu0v24N3BHBQHi0ZBt
         6ungp+LpdgfYbrRB/60ci9Ge41ZPODaFqLNatwJLTyK/rLewzEBvoihjPUXMw0RHYD3v
         NmCoLqHTRG1tYkxS0sqRMKKCkkS7+fS5AYp/I/2WG0XiEO/p8eL+h4hQyqb3OZdCN/BV
         H4g9OuUXiS5Ko3qn7WFhlmwUjGm4O7KL0IGbSNtGOSfUrlPx3qJRdFbqCdyjhnCMYVEv
         Nbbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=Ul5rn3TEwoKFWJAM7LDQzFG0ycKQ5Z8xC5TsjVChqI0=;
        b=SiTaGGFg5H8LtwRU24fMAVfqVlUdOt0ddk1l+tGvtApWQrq0zKAfgKw92oM4Zxy44n
         UvLgqJR3EbpOvZ+/TaaxrunEWc4k0pLDyLfz06cMHVuNQ2O8v5g/TvtCa+mXuyM5cAFj
         O6Fg5Hyt2Nbu61UMSdbWBlZU1ntCbndVn2bDefxvdC1tYVNlvF/0ZBkJMlCacc+/m0++
         j3dWG2gatrIRC9Pz/FfdE3uPkUHn1DO/hb2t3aHIkVpUost7RStvv1kf3i1vI68ve3MZ
         zgX7sXwzrmFAZRzoX+A2dMo4JLosoA9cwsvn0RrAvsWTvP9HYejSYTR/ebF1xktpszXs
         fTHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id a5si44720488pff.39.2019.04.14.23.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 23:18:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x3F6HtwV027472
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 15 Apr 2019 15:17:55 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x3F6HtqE015285;
	Mon, 15 Apr 2019 15:17:55 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x3F6Fq61013686;
	Mon, 15 Apr 2019 15:17:55 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-4282291; Mon, 15 Apr 2019 15:16:17 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0319.002; Mon,
 15 Apr 2019 15:16:16 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: Yufen Yu <yuyufen@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
Thread-Topic: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
Thread-Index: AQHU8OP8ZTn3PhPu/UCJqntzyAiSIqY4mW+AgAOTYgA=
Date: Mon, 15 Apr 2019 06:16:15 +0000
Message-ID: <20190415061618.GA16061@hori.linux.bs1.fc.nec.co.jp>
References: <20190412040240.29861-1-yuyufen@huawei.com>
 <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
In-Reply-To: <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7E06C9F5BFF16F4F9FBCB0F83D6CDD08@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 04:40:01PM -0700, Mike Kravetz wrote:
> On 4/11/19 9:02 PM, Yufen Yu wrote:
> > Commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
> ...
> > However, for inode mode that is 'S_ISBLK', hugetlbfs_evict_inode() may
> > free or modify i_mapping->private_data that is owned by bdev inode,
> > which is not expected!
> ...
> > We fix the problem by moving resv_map to hugetlbfs_inode_info. It may
> > be more reasonable.
>=20
> Your patches force me to consider these potential issues.  Thank you!
>=20
> The root of all these problems (including the original leak) is that the
> open of a block special inode will result in bd_acquire() overwriting the
> value of inode->i_mapping.  Since hugetlbfs inodes normally contain a
> resv_map at inode->i_mapping->private_data, a memory leak occurs if we do
> not free the initially allocated resv_map.  In addition, when the
> inode is evicted/destroyed inode->i_mapping may point to an address space
> not associated with the hugetlbfs inode.  If code assumes inode->i_mappin=
g
> points to hugetlbfs inode address space at evict time, there may be bad
> data references or worse.

Let me ask a kind of elementary question: is there any good reason/purpose
to create and use block special files on hugetlbfs?  I never heard about
such usecases.  I guess that the conflict of the usage of ->i_mapping is
discovered recently and that's because block special files on hugetlbfs are
just not considered until recently or well defined.  So I think that we mig=
ht
be better to begin with defining it first.

I tried the procedure described in commit 58b6e5e8f1a ("hugetlbfs: fix
memory leak for resv_map") and I failed to open the block special file with
ENXIO. So I'm not clearly sure what to solve.
I tried a similar test on tmpfs (good reference for hugetlbfs) and that als=
o
failed on opening block file on it (but with EACCESS), so simply fixing it
similarly could be an option if there's no reasonable usecase and we just
want to fix the memory leak.=20

>=20
> This specific part of the patch made me think,
>=20
> > @@ -497,12 +497,15 @@ static void remove_inode_hugepages(struct inode *=
inode, loff_t lstart,
> >  static void hugetlbfs_evict_inode(struct inode *inode)
> >  {
> >  	struct resv_map *resv_map;
> > +	struct hugetlbfs_inode_info *info =3D HUGETLBFS_I(inode);
> > =20
> >  	remove_inode_hugepages(inode, 0, LLONG_MAX);
> > -	resv_map =3D (struct resv_map *)inode->i_mapping->private_data;
> > +	resv_map =3D info->resv_map;
> >  	/* root inode doesn't have the resv_map, so we should check it */
> > -	if (resv_map)
> > +	if (resv_map) {
> >  		resv_map_release(&resv_map->refs);
> > +		info->resv_map =3D NULL;
> > +	}
> >  	clear_inode(inode);
> >  }
>=20
> If inode->i_mapping may not be associated with the hugetlbfs inode, then
> remove_inode_hugepages() will also have problems.  It will want to operat=
e
> on the address space associated with the inode.  So, there are more issue=
s
> than just the resv_map.  When I looked at the first few lines of
> remove_inode_hugepages(), I was surprised to see:
>=20
> 	struct address_space *mapping =3D &inode->i_data;
>=20
> So remove_inode_hugepages is explicitly using the original address space
> that is embedded in the inode.  As a result, it is not impacted by change=
s
> to inode->i_mapping.  Using git history I was unable to determine why
> remove_inode_hugepages is the only place in hugetlbfs code doing this.
>=20
> With this in mind, a simple change like the following will fix the origin=
al
> leak issue as well as the potential issues mentioned in this patch.
>=20
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 53ea3cef526e..9f0719bad46f 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -511,6 +511,11 @@ static void hugetlbfs_evict_inode(struct inode *inod=
e)
>  {
>  	struct resv_map *resv_map;
> =20
> +	/*
> +	 * Make sure we are operating on original hugetlbfs address space.
> +	 */
> +	inode->i_mapping =3D &inode->i_data;
> +
>  	remove_inode_hugepages(inode, 0, LLONG_MAX);
>  	resv_map =3D (struct resv_map *)inode->i_mapping->private_data;
>  	/* root inode doesn't have the resv_map, so we should check it */
>=20
>=20
> I don't know why hugetlbfs code would ever want to operate on any address
> space but the one embedded within the inode.  However, my uderstanding of
> the vfs layer is somewhat limited.  I'm wondering if the hugetlbfs code
> (helper routines mostly) should perhaps use &inode->i_data instead of
> inode->i_mapping.  Does it ever make sense for hugetlbfs code to operate
> on inode->i_mapping if inode->i_mapping !=3D &inode->i_data ?

I'm not a fs expert, but &inode->i_data seems safer pointer to reach to
the struct address_space because it's embedded in inode and always exists.

Thanks,
Naoya Horiguchi=

