Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ECACC10F0E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:00:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB2532084B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:00:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB2532084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EB806B0003; Mon, 15 Apr 2019 20:00:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39B0F6B0006; Mon, 15 Apr 2019 20:00:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28E616B0007; Mon, 15 Apr 2019 20:00:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6A356B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 20:00:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u2so11326518pgi.10
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 17:00:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=oxaLcbw8XXAIbHjRAWkItIasUOt0NVXXie7GNqHswUA=;
        b=HmyFrOiQ3Yl0CIIrJtOMAQDycrRRST+cY/AAoHtp0Zoe1e/lyNte632JvLyfdv1uoU
         gDt2BTdkGTgseCadpzJZaGyc3YqEfDrbkYV0tCTLTxSJD012GkYDJJMaFtOpQe05nu03
         Uaa36QjJgEUXmuO/E9uH83JegtUN7Y6v6/e0M/U/0Nvof2HQ7uK1jRxOqcF/Dp3AU0lD
         gp2ZY4Uj9LAkPk7jsblct1IyqS/XBgL12wRkD2u8C5lPFtRddfiUP+SyGbsNS/w5/2hd
         x+zPD2+zzJIehSVKaDFpcOTpZ3J48gSRzLtWHb/3/3hGTKEg4rvm+5bkzPvV3Ae3cNQk
         v0bQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAWU7qe7ZrzVTBnZ0ErFHxsn4ztxCIYhJKRaGyskKF4vA7gwK5f4
	wamMowDijHMyPyoj/GY7HRo6bdSdOA5wvufq3uzQG6uBOT6Q/sXzxYXSl/6q1OXvNkzQ4ywXfMI
	zDWQOdJOn0+ZI2BgPW52rrI/LaylrzY2ungdNzryBaTIQeSQLA2WtW9h6zeNrhk8qQw==
X-Received: by 2002:a62:e412:: with SMTP id r18mr78427011pfh.207.1555372832474;
        Mon, 15 Apr 2019 17:00:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6wdUM0z3jG4HTTGagFxF7gpKgqNnA0XNWpRdEby5iu37//3OEznhqM2Pt+Nxw99A3X1d3
X-Received: by 2002:a62:e412:: with SMTP id r18mr78426813pfh.207.1555372830661;
        Mon, 15 Apr 2019 17:00:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555372830; cv=none;
        d=google.com; s=arc-20160816;
        b=CEqT5G6FWotwHiXT9QwkdofY2vMHkVLKKczGciXpNwewxAC7rqPO0O5BUuAvw/v8cK
         9wn1bmrZrZbzPt/7mIBkDiC9gJDzDu/ceJt+nbU50zfKiIrJRHTyfVu9jNMb4sQQN2iS
         DUwXAoGnYmvyO6tVKMPbBRi1XL71P2oMJpB0haZVIX2mk4sE3Jmu57r4IqhUujbxFolr
         zrbK7cLmW9I56lqtEr++HxqetFBrNrCmYgRd8a8eBU7cVcJa/6JwrF6LxeMP4g4quWOa
         XXNcgB46ouYox1JRmkPMysKPY75RNO9P81omryr49oeMLkriReUnsZMHEgpLIJ56CLPT
         qVYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=oxaLcbw8XXAIbHjRAWkItIasUOt0NVXXie7GNqHswUA=;
        b=Z5gk/ZgCHvmXEw1ClYRxzV8jhFFMZwyvxhrT7hCCvttUM9VeFltzCX5PlBd7PogCBa
         C7lrHnqui0Ntx0AGzwJ+kXXejKm+0tdfclkKc7sMcc5bwTEhDWBl16+WbHjHaf0qot3F
         m6GNpb+OzEuPomaDHbYFwaslmB57g2JRiUTfvnAQ9EXr2wRokWWlsHQ7M/Nqk4Zuw+Nu
         PvQvjlY9JCi3m3IFlOeXIEQSLqVuM66FPk1yhFV2RXi9M4j1N1dajc+WFAVe1S5uZL/H
         aB5iwvxXS7jw2ZYl4/huAAIeNVuy6lf2gIhV8hXSNwAIBRnudeh74DJcstmS97stMshN
         ogvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id c2si46567121pls.226.2019.04.15.17.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 17:00:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x3G00IOJ028577
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 16 Apr 2019 09:00:18 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x3G00Ieh021115;
	Tue, 16 Apr 2019 09:00:18 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x3FNwj0Y031032;
	Tue, 16 Apr 2019 09:00:18 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-4307468; Tue, 16 Apr 2019 08:59:45 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0319.002; Tue,
 16 Apr 2019 08:59:44 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: Michal Hocko <mhocko@kernel.org>, Yufen Yu <yuyufen@huawei.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
Thread-Topic: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
Thread-Index: AQHU8OP8ZTn3PhPu/UCJqntzyAiSIqY4mW+AgAOTYgCAADHuAIAAhSyAgAByBwA=
Date: Mon, 15 Apr 2019 23:59:44 +0000
Message-ID: <20190415235946.GA4465@hori.linux.bs1.fc.nec.co.jp>
References: <20190412040240.29861-1-yuyufen@huawei.com>
 <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
 <20190415061618.GA16061@hori.linux.bs1.fc.nec.co.jp>
 <20190415091500.GG3366@dhcp22.suse.cz>
 <f063c3e7-1b37-7592-14c2-78b494dbd825@oracle.com>
In-Reply-To: <f063c3e7-1b37-7592-14c2-78b494dbd825@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.148]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <13F865A1312F9D48B9E5F267F622D3A9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 10:11:39AM -0700, Mike Kravetz wrote:
> On 4/15/19 2:15 AM, Michal Hocko wrote:
> > On Mon 15-04-19 06:16:15, Naoya Horiguchi wrote:
> >> On Fri, Apr 12, 2019 at 04:40:01PM -0700, Mike Kravetz wrote:
> >>> On 4/11/19 9:02 PM, Yufen Yu wrote:
> >>>> Commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
> >>> ...
> >>>> However, for inode mode that is 'S_ISBLK', hugetlbfs_evict_inode() m=
ay
> >>>> free or modify i_mapping->private_data that is owned by bdev inode,
> >>>> which is not expected!
> >>> ...
> >>>> We fix the problem by moving resv_map to hugetlbfs_inode_info. It ma=
y
> >>>> be more reasonable.
> >>>
> >>> Your patches force me to consider these potential issues.  Thank you!
> >>>
> >>> The root of all these problems (including the original leak) is that =
the
> >>> open of a block special inode will result in bd_acquire() overwriting=
 the
> >>> value of inode->i_mapping.  Since hugetlbfs inodes normally contain a
> >>> resv_map at inode->i_mapping->private_data, a memory leak occurs if w=
e do
> >>> not free the initially allocated resv_map.  In addition, when the
> >>> inode is evicted/destroyed inode->i_mapping may point to an address s=
pace
> >>> not associated with the hugetlbfs inode.  If code assumes inode->i_ma=
pping
> >>> points to hugetlbfs inode address space at evict time, there may be b=
ad
> >>> data references or worse.
> >>
> >> Let me ask a kind of elementary question: is there any good reason/pur=
pose
> >> to create and use block special files on hugetlbfs?  I never heard abo=
ut
> >> such usecases.
>=20
> I am not aware of this as a common use case.  Yufen Yu may be able to pro=
vide
> more details about how the issue was discovered.  My guess is that it was
> discovered via code inspection.
>=20
> >>                 I guess that the conflict of the usage of ->i_mapping =
is
> >> discovered recently and that's because block special files on hugetlbf=
s are
> >> just not considered until recently or well defined.  So I think that w=
e might
> >> be better to begin with defining it first.
>=20
> Unless I am mistaken, this is just like creating a device special file
> in any other filesystem.  Correct?  hugetlbfs is just some place for the
> inode/file to reside.  What happens when you open/ioctl/close/etc the fil=
e
> is really dependent on the vfs layer and underlying driver.
>=20

OK. Generally speaking, "special files just work even on hugetlbfs" sounds
fine for me if it properly works.

> > A absolutely agree. Hugetlbfs is overly complicated even without that.
> > So if this is merely "we have tried it and it has blown up" kinda thing
> > then just refuse the create blockdev files or document it as undefined.
> > You need a root to do so anyway.
>=20
> Can we just refuse to create device special files in hugetlbfs?  Do we ne=
ed
> to worry about breaking any potential users?  I honestly do not know if a=
nyone
> does this today.  However, if they did I believe things would "just work"=
.
> The only known issue is leaking a resv_map structure when the inode is
> destroyed.  I doubt anyone would notice that leak today.

Thanks for explanation, so that's unclear now.=20

>=20
> Let me do a little more research.  I think this can all be cleaned up by
> making hugetlbfs always operate on the address space embedded in the inod=
e.
> If nothing else, a change or explanation should be added as to why most c=
ode
> operates on inode->mapping and one place operates on &inode->i_data.

Sounds nice, thank you.

(Just for sharing point, not intending to block the fix ...)
My remaining concern is that this problem might not be hugetlbfs specific,
because what triggers the issue seems to be the usage of inode->i_mapping.
bd_acquire() are callable from any filesystem, so I'm wondering whether we
have something to generally prevent this kind of issue?

Thanks,
Naoya Horiguchi=

