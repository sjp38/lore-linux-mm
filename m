Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0857BC282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:06:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B41402175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:06:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B41402175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EEA98E0045; Thu,  7 Feb 2019 11:06:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 478228E0002; Thu,  7 Feb 2019 11:06:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32A3C8E0045; Thu,  7 Feb 2019 11:06:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 030928E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:06:09 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id y8so289501qto.19
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:06:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=63d+u1u7A065ck32eOMqOzgO0ToTxA9DRZ01BIxAvWs=;
        b=ZqxSrzXh5A6GXSRA2+/fWjHZhXBaZmqkPftcf1E7PBFgS1liiFijnNlFBFZInHmUuI
         wq3lqsUEw1sOwaVM+41yfnP2NdhvrEqWgJ04saqZA67M0aUOI4mQdXTk5/RAfzwyVgCz
         n8E7j4J8yQtqEPKFm7yXDtx1NrEw4otFLqtRgWstSFNwcXGbQBJ5tmUBu9OdauUe6FAQ
         b0eHWThwei9vmflZW+Uf0y8PrQ5Va/Xiy9vnBbHAcEoqThVD1JA1VF0uoyFG364av5O4
         ESiiSZa5lGoxwYtnEl4cTl4bm7SHkksGUhdhn5RO8MlRszzffDJDvChKwLblWBlpAn0M
         QNhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubY6kJjsdXXav3RLf1AX6lHs0qaXMxxCdYCG4SwMmiRt3B1FN8v
	zKLF3vgPV+ZeuGh+qRCJSh8XiuA8qU12gyj4HPAMF+6wGG9eVrwh+x4q3oZWa3ZPuGRCqWdgdfL
	UHvNoTfary2HXJ3iDZ3i4+TL7opmJyQI4zsjwGkeTlNgBdw/6GGC+5xqFtRj0AjW05w==
X-Received: by 2002:ac8:518f:: with SMTP id c15mr3069900qtn.116.1549555568737;
        Thu, 07 Feb 2019 08:06:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZKq847UrNL7u3aYLrbtnpULT4bnSD1PGzxsvmrAFyIJgXoMezU9XAJXj+ugLCWovWodWzw
X-Received: by 2002:ac8:518f:: with SMTP id c15mr3069865qtn.116.1549555568213;
        Thu, 07 Feb 2019 08:06:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549555568; cv=none;
        d=google.com; s=arc-20160816;
        b=BRAqoCvR5f1dF4OKSm+A4R471d2qA6RWr3PYt4oio0E9zkXuNE/yg2X7r87JHPKPFB
         4VlUYLpiJ0laebF3GKYdyPkcs6YRveQUSgIM8wU5oTDtAytmvUwS1RTRSf1IwadTl3xh
         qtTg4su4p0aIbzBdj6zqkI1qMzNwW9aRgt+Nnmze131LpVJ4wU9hUmBqxujNRUtS27zj
         PZIAE+vpOGAB/vLrpg2lW4MIisTJuGpTeTvI6pB9Z28Y2ok+e6ISjzJof1VVT7ap8QuO
         lj7RQb/u3p3aUbbG7Lzddl6TlydZ6dBoP3GKeNG91wntm3Q47XkydgzSE6OxE7wa1CCa
         dRCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=63d+u1u7A065ck32eOMqOzgO0ToTxA9DRZ01BIxAvWs=;
        b=rfn2hrmj+ABok4WGwnqkWTpTdiOaQewGJjpoUv1zP6IGzSR8ssJRVWHmwEP0XS26ky
         gy3qhon6vVjHWhbwYrkXHXBwtbiGLayevCnhg4U7XZ1sJ/2T90PsKP24A+swowpnlUqO
         HG/nJNlS4xjv/EOzabVOlk0oB3hlHniHDNsCRwMSowvC+iCucsB4fVMDzaUJui0x514w
         GUfXVLrvB7r1zOPsSq1IFDlL2qmGVfV9YfavaRV6ouF6vYqTvGU4ohe+E+5IA4NcrSgC
         tge97hX/6ATDBuYMebl/8V8fn3fRO3ooZBgOTYa+OX8u3mj8cLwF47xKSznAdikQ7Wjp
         5mzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x1si7509608qkc.167.2019.02.07.08.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 08:06:08 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x17G5wDj062241
	for <linux-mm@kvack.org>; Thu, 7 Feb 2019 11:06:07 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qgqfvhmt8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 07 Feb 2019 11:06:06 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 7 Feb 2019 16:05:04 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 7 Feb 2019 16:04:56 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x17G4tNl8913356
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 7 Feb 2019 16:04:55 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E367211C058;
	Thu,  7 Feb 2019 16:04:54 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 79A8F11C052;
	Thu,  7 Feb 2019 16:04:52 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  7 Feb 2019 16:04:52 +0000 (GMT)
Date: Thu, 7 Feb 2019 18:04:50 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
        Rik van Riel <riel@surriel.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com,
        Peter Zijlstra <peterz@infradead.org>,
        Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com,
        iamjoonsoo.kim@lge.com, treding@nvidia.com,
        Kees Cook <keescook@chromium.org>,
        Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de,
        hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie,
        oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com,
        Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
        Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org,
        linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org,
        linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org,
        iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
 <20190131083842.GE28876@rapoport-lnx>
 <CAFqt6za9xA_8OKiaaHXcO9go+RtPdjLY5Bz_fgQL+DZbermNhA@mail.gmail.com>
 <20190207155700.GA8040@rapoport-lnx>
 <CAFqt6zbE0JD09ibp3jZ0rr5xp52SEK+Pi6pGMQwSp_=d0edy7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zbE0JD09ibp3jZ0rr5xp52SEK+Pi6pGMQwSp_=d0edy7g@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19020716-0028-0000-0000-00000345D191
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020716-0029-0000-0000-00002403E2F7
Message-Id: <20190207160450.GB8040@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-07_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=968 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902070122
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 09:37:08PM +0530, Souptick Joarder wrote:
> On Thu, Feb 7, 2019 at 9:27 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > Hi Souptick,
> >
> > On Thu, Feb 07, 2019 at 09:19:47PM +0530, Souptick Joarder wrote:
> > > Hi Mike,
> > >
> > > Just thought to take opinion for documentation before placing it in v3.
> > > Does it looks fine ?
> >
> > Overall looks good to me. Several minor points below.
> 
> Thanks Mike. Noted.
> Shall I consider it as *Reviewed-by:* with below changes ?
 
Yeah, sure.

> >
> > > +/**
> > > + * __vm_insert_range - insert range of kernel pages into user vma
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + * @offset: user's requested vm_pgoff
> > > + *
> > > + * This allow drivers to insert range of kernel pages into a user vma.
> >
> >           allows
> > > + *
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > > +                               unsigned long num, unsigned long offset)
> > >
> > >
> > > +/**
> > > + * vm_insert_range - insert range of kernel pages starts with non zero offset
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + *
> > > + * Maps an object consisting of `num' `pages', catering for the user's
> >                                    @num pages
> > > + * requested vm_pgoff
> > > + *
> > > + * If we fail to insert any page into the vma, the function will return
> > > + * immediately leaving any previously inserted pages present.  Callers
> > > + * from the mmap handler may immediately return the error as their caller
> > > + * will destroy the vma, removing any successfully inserted pages. Other
> > > + * callers should make their own arrangements for calling unmap_region().
> > > + *
> > > + * Context: Process context. Called by mmap handlers.
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> > > +                               unsigned long num)
> > >
> > >
> > > +/**
> > > + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> > > + * @vma: user vma to map to
> > > + * @pages: pointer to array of source kernel pages
> > > + * @num: number of pages in page array
> > > + *
> > > + * Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to
> >
> >                                                                   the offset
> >
> > > + * 0. This function is intended for the drivers that did not consider
> > > + * @vm_pgoff.
> > > + *
> > > + * Context: Process context. Called by mmap handlers.
> > > + * Return: 0 on success and error code otherwise.
> > > + */
> > > +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> > > +                               unsigned long num)
> > >
> >
> > --
> > Sincerely yours,
> > Mike.
> >
> 

-- 
Sincerely yours,
Mike.

