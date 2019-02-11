Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0BD1C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62CE8214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:15:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62CE8214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E47D8E0167; Mon, 11 Feb 2019 16:15:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0928F8E0165; Mon, 11 Feb 2019 16:15:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E76408E0167; Mon, 11 Feb 2019 16:15:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF278E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:15:00 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id k10so328699pfi.5
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:15:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=8YyqeJuE3a+YmuZJDfL3AeKrem/uQr8+IZ/9CeD+Mbc=;
        b=it/8NRDQdUq4FFm/x2ZM4IeKv6Z9IhMJ6+GxMOcxCnvunySzWD18Ztf3GjCAJW6aCr
         fEnyr4CAcWkEeWgvv8l8fDFFpsi83Wc2QDzez5NIopgTD/p13pl9rgDOmcf+pydM4D5w
         XwjoYGxeEsGaKPn+78WYJ5DtnYFL1WrDWRuVbGcF6YW+Z74WfHKF25pcVnP5TO+G0+SV
         3SZay6pce4kkUCLfmmdl8+NTwD8/OAjR1T6pdOd24lqergWYz9QT+jYRgJyikXDemQ3y
         zJWzVDXDRIJ8kt6WkSdjTuAlDK2djDrspI5m3by8kBxgzNstxZAOaQqjSdRIfu+FN3nl
         F2kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYedf9ZbMkslHolwetk+4bho8EFUG430oPLOWHHpF1pNyTkyKBe
	Bvd3siOc3Dzyksecp8jsuOoBilomdQy/pjHTbyTXXHC49Wnd22lLgzQtLFDGL31wRxoI0fJlqvz
	zswgZAv4O6HFZ3v3neORQuUXWuKjll32LDHBKuZkYtE7xGbLQhmjE5a/Y59r6Y9WRyQ==
X-Received: by 2002:a62:f54d:: with SMTP id n74mr285857pfh.98.1549919700345;
        Mon, 11 Feb 2019 13:15:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY0jQOVuPk9TaXwZ+a20Oq27Piny2DiugFE7biUbkKOM8heY4p1MhUyG3C2wExZMeVDYd0G
X-Received: by 2002:a62:f54d:: with SMTP id n74mr285812pfh.98.1549919699710;
        Mon, 11 Feb 2019 13:14:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549919699; cv=none;
        d=google.com; s=arc-20160816;
        b=yxKLV1Y/5JtLtJne9vs4BwAX0pD8dBICglcwj/UEA8mUTMUaGXPgEP9o++UFBOYYRi
         tyIxNiJ/QQqupVSmprNEM2kCfcxNK+B2+mD09MgjJaDCZRGCWnmtTkygDRknovarEFzW
         /bx99zDI47M/Vcdso9q2/4+M64zXporcSuqLMjqU8a39FlNT99cT0uoggFYbV6OAdmti
         LFoFi0Yd/R6QjAE45B8msGAnN7C4pjQNSMROB5OJsIjRt0R941KgjQmzqXdV3KAXlqMO
         RTJpopOIOekMDCggqgLSnTxi8p/H7SpaeSzgbLwc3TKf97u7HkCgADS0cSqZjX3H3NRG
         YUAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=8YyqeJuE3a+YmuZJDfL3AeKrem/uQr8+IZ/9CeD+Mbc=;
        b=haNerhE99AvF6nxoMMzZvSLb1qQz5+H3zkS2tEudQo6JlgZiQ+j2XP0mXaAoEG05M7
         JpiU4yO2LbXEuw6Z2VJTbtM5TMqKeNoztdnncWyRHlZkczdWMw5nIq3vJbkAgxFjFicY
         LWJc7pRdkI6W7Vq8Woez1KFVr7NlZML6WkbOxJ+uMOZNz1hnriTd+8nw/A5fMsZw7+GG
         ldobqWZ4WIaQGbyJ33IoxYssR6z5t7+/nt3quKPD68upSMT35an9SXtBi4A4CqiohB9A
         JArMZQ6CiipHZLoNyGbS5znvD3soq7paCbd/dUIM1bIlqLhPpo04icswGOVRBB5Bt/HC
         G6IA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z128si10231706pgb.372.2019.02.11.13.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:14:59 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 13:14:59 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="145995188"
Received: from fmsmsx107.amr.corp.intel.com ([10.18.124.205])
  by fmsmga001.fm.intel.com with ESMTP; 11 Feb 2019 13:14:59 -0800
Received: from fmsmsx112.amr.corp.intel.com (10.18.116.6) by
 fmsmsx107.amr.corp.intel.com (10.18.124.205) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 13:14:58 -0800
Received: from crsmsx103.amr.corp.intel.com (172.18.63.31) by
 FMSMSX112.amr.corp.intel.com (10.18.116.6) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 13:14:58 -0800
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.57]) by
 CRSMSX103.amr.corp.intel.com ([169.254.4.180]) with mapi id 14.03.0415.000;
 Mon, 11 Feb 2019 15:14:56 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Daniel Borkmann
	<daniel@iogearbox.net>, Davidlohr Bueso <dave@stgolabs.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Marciniszyn, Mike"
	<mike.marciniszyn@intel.com>, "Dalessandro, Dennis"
	<dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, "Andrew
 Morton" <akpm@linux-foundation.org>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, "Williams, Dan J"
	<dan.j.williams@intel.com>
Subject: RE: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Thread-Topic: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Thread-Index: AQHUwkbGJiw3VF3kpESe1yhfT7MilqXbdCyA//+kDNA=
Date: Mon, 11 Feb 2019 21:14:56 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79BCF04C@CRSMSX101.amr.corp.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211204049.GB2771@ziepe.ca>
In-Reply-To: <20190211204049.GB2771@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMDFlNTkxMjgtNDFmNi00OWJhLWIxNDUtZmUwNDU4NzYzYjBhIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiQytYTmd4U0ErY3oyVTdaUEw3K3VoZjBEOHlcL0hmcWI0ZmlWXC9uRVhLNHRNZGlhbGNtSVJFaEhRa3JjN1wvSERYRCJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.400.15
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>=20
> On Mon, Feb 11, 2019 at 12:16:40PM -0800, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> >
> > NOTE: This series depends on my clean up patch to remove the write
> > parameter from gup_fast_permitted()[1]
> >
> > HFI1 uses get_user_pages_fast() due to it performance advantages.
> > Like RDMA,
> > HFI1 pages can be held for a significant time.  But
> > get_user_pages_fast() does not protect against mapping of FS DAX pages.
>=20
> If HFI1 can use the _fast varient, can't all the general RDMA stuff use i=
t too?
>=20
> What is the guidance on when fast vs not fast should be use?

Right now it can't because it holds mmap_sem across the call.  Once Shiraz'=
s patches are accepted removing the umem->hugetlb flag I think we can chang=
e  umem.c.

Also, it specifies FOLL_FORCE which can't currently be specified with gup f=
ast.  One idea I had was to change get_user_pages_fast() to use gup_flags i=
nstead of a single write flag.  But that proved to be a very big cosmetic c=
hange across a lot of callers so I went this way.

Ira

>=20
> Jason

