Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18FA3C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:49:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6E0720811
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 15:49:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6E0720811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 868E88E0004; Thu, 14 Mar 2019 11:49:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 819818E0001; Thu, 14 Mar 2019 11:49:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 730278E0004; Thu, 14 Mar 2019 11:49:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4508A8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 11:49:19 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m17so6682906pgk.3
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 08:49:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:to:cc:subject:references:in-reply-to:mime-version
         :content-transfer-encoding:content-disposition;
        bh=9pA0ManLNPhyO6eoAcrk+WeNdslIF1O9o9zVlPlmdGA=;
        b=j8eBJaT+/6sMBNrYBLHdUabv6ZcafAIeWho3MqJcd2IS+xmu2BySg+5XLYmu+mbBWl
         TUcJzjpf1rKanrW1xbyFyRZEICOARaR2hJ+Jy9XuUkoyMT40zWuYVYiQVSt+0kiyHJw8
         WtLYRxZd+sYykwXEMyCwMNEpGeAAkK6dsC3SWDfoKvIFX5eoYnttmIuhqmoDAnm2fyyR
         QrTasrltryRniNupLUIushAzI8j38qezIR1kf1iXEe0+zFkKWfvczKO2q8oda/Nw7G5D
         pz6VPrHjHKr4KIK/0q2b46g4vWm292QApWilApQJHzCftLj8svMlarM2kMRLUZ0HNON/
         oRFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jbeulich@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=JBeulich@suse.com
X-Gm-Message-State: APjAAAX71FiT6ZgkZR9avp9cZcyRVSl1jgmnOojr+gJe/xjHfh1sg5Ri
	D7VWERKbStheOHwTLWsoGiStcnE7RPZ7R6Y3cxTi7WXoD2k4RW3ZsHIOnRNK7taLlVdNarNDjSB
	oVqh+nE5ybgcGEHQuqlK4+V3H7miIv5j5O8Oipd88chr930qcl67VGnYEPmM5BqmLGQ==
X-Received: by 2002:a63:2c50:: with SMTP id s77mr28861715pgs.440.1552578558985;
        Thu, 14 Mar 2019 08:49:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjkJrIKzmPBezSFcgeC5/kM5TZcPhqUpnNoncbxqTlSlE2yPpHtxaY4MPsnecU5W7mZ2Xv
X-Received: by 2002:a63:2c50:: with SMTP id s77mr28861651pgs.440.1552578558105;
        Thu, 14 Mar 2019 08:49:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552578558; cv=none;
        d=google.com; s=arc-20160816;
        b=rgVHhbBSE5FaHou+hpFWno3wVIZDcH0J3dUpIM1Tf4sYLP/W15fS12xPlH0pXyLc75
         GeI5cJhY9OyzsjRQQwLpW+8QPxYdP7D0+kVNLx86YrClenM1Fj4fv4SCwWpRcJ9Vipzr
         Dbda90ZbvKQ1l5yTaKA7/DXJ8ipnoiffLbdLmwMcg/aVcMjXvIvA9ra+Tn4Vk7T+8wyK
         7BmsAUO9/24W8SUKhvBR9v9N8BPIdhoXV6G+EIz5FRSSOmGiBSte9/F+qpQ4Q77r09Hc
         91A5Boy1svID6y4FuSvXCRLKm6u0pS4QWJptwL0P/U0c+h+y58o3IsrC4FM8egG1u4TD
         7osw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:content-transfer-encoding:mime-version
         :in-reply-to:references:subject:cc:to:from:date:message-id;
        bh=9pA0ManLNPhyO6eoAcrk+WeNdslIF1O9o9zVlPlmdGA=;
        b=fTwuFx3iSiSg5ChrELM0moOJN/hN8dBDwbMAEJ92ZH7pf5n4n0z3KqkjYGxoqSRCsI
         rIWhlKYFmrWUCo/74wgCbJd876h5HC2UvBKH+TM9h17wGmYglNex66zdtJl5HIG46gpY
         GBuY6HMCZg8pppYXce3dZw8IVQwWzCk73awb6Q3OCFZJ4mOdEnK5vO1fIiivzLdGytaT
         G9o4NBJJQ4nvoJG+6CHSUq4OKAa4M8lGD6DyInz3nkSbuhDpAqRYVT1F2N+Ihcbefdqz
         0sMqAQDJKBLveeg2dOsWtyrpmiOHySYxjUHKQULLfI9dkmE8qWZ3b9io1cDrTraXRQEw
         Zt+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jbeulich@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=JBeulich@suse.com
Received: from prv1-mh.provo.novell.com (prv1-mh.provo.novell.com. [137.65.248.33])
        by mx.google.com with ESMTPS id j11si170787pfh.47.2019.03.14.08.49.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 08:49:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jbeulich@suse.com designates 137.65.248.33 as permitted sender) client-ip=137.65.248.33;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jbeulich@suse.com designates 137.65.248.33 as permitted sender) smtp.mailfrom=JBeulich@suse.com
Received: from INET-PRV1-MTA by prv1-mh.provo.novell.com
	with Novell_GroupWise; Thu, 14 Mar 2019 09:49:17 -0600
Message-Id: <5C8A77FD020000780021EC87@prv1-mh.provo.novell.com>
X-Mailer: Novell GroupWise Internet Agent 18.1.0 
Date: Thu, 14 Mar 2019 09:49:17 -0600
From: "Jan Beulich" <JBeulich@suse.com>
To: "David Hildenbrand" <david@redhat.com>
Cc: "Julien Grall" <julien.grall@arm.com>,
 "Andrew Cooper" <andrew.cooper3@citrix.com>,
 "Matthew Wilcox" <willy@infradead.org>,
 "Stefano Stabellini" <sstabellini@kernel.org>,<linux-mm@kvack.org>,
 <akpm@linux-foundation.org>,
 "xen-devel" <xen-devel@lists.xenproject.org>,
 "Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
 "Juergen Gross" <jgross@suse.com>, <linux-kernel@vger.kernel.org>,
 "Nadav Amit" <namit@vmware.com>
Subject: Re: [Xen-devel] [PATCH v1] xen/balloon: Fix mapping PG_offline
 pages to user space
References: <20190314154025.21128-1-david@redhat.com>
In-Reply-To: <20190314154025.21128-1-david@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>>> On 14.03.19 at 16:40, <david@redhat.com> wrote:
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -604,6 +604,7 @@ int alloc_xenballooned_pages(int nr_pages, struct =
page **pages)
>  	while (pgno < nr_pages) {
>  		page =3D balloon_retrieve(true);
>  		if (page) {
> +			__ClearPageOffline(page);
>  			pages[pgno++] =3D page;

While this one's fine, ...

> @@ -646,6 +647,7 @@ void free_xenballooned_pages(int nr_pages, struct =
page **pages)
> =20
>  	for (i =3D 0; i < nr_pages; i++) {
>  		if (pages[i])
> +			__SetPageOffline(pages[i]);
>  			balloon_append(pages[i]);
>  	}

... I think you want to add a pair of braces here.

Jan


