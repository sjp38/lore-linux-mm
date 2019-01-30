Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94E07C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:01:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 636D120869
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:01:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 636D120869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAA318E0003; Wed, 30 Jan 2019 13:01:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B301B8E0001; Wed, 30 Jan 2019 13:01:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 984E38E0003; Wed, 30 Jan 2019 13:01:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBD28E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:01:37 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id p4so212388pgj.21
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:01:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=piRmYJDBFeS09Si2+LQuH+h2chqilpk+NrEIsPZRwPw=;
        b=cWSXr0DqaOX2gDkwo5efROd232QZIjahegCUH1UrT12VfRTcrGalbrd6M58HPEBYL1
         nVn7BrC+GeXfU23NRo1IpmkVJIWZ9Z3QH8r7PQGp73Y5Le2000o3oc15HmjmhYdA7N7C
         zDp1jW6sAOzTE5hvae+/6o32avuvC5Dl7Wtks2kE89OQXi4VO35uz1755tMipZah3d3J
         TwHSYby4pW1F0zWt0RXSzW1B081ph90bO/Dge8dyrEcl87fmuiT51Fgx6wK5gpW0mfNe
         In3GNdUob4EITy4RPEcxXCbn97hbbVCxdssS9Zgsrb2NtJx2ZyFBhiolzZZkslgX6WQ8
         fSjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcrLspEfpv2mUU7SESuWUrzHMCB9SrjZ+1XYnnPSxrniU1eV4M+
	vK4Sa4AU/afdCU/BgLrkz3N1iZsPWD3zctLo03peQml4IkNJQT0r5gPsqcACvB5ymZGmBHrvGU3
	bdtxfhaCiCCr0sM/KME8WwJEi1+Wkvd8MDQwaCJcSLL/jnLaaO8c6f3uiDYHiYoQWrA==
X-Received: by 2002:a63:4a4d:: with SMTP id j13mr28887682pgl.127.1548871296959;
        Wed, 30 Jan 2019 10:01:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5lCIJeaYbRBY+PPKMnH3f2wg21QsgER9XnuEGtJlKtrn6cM/X+LPWDWc2PUM9dfgn6L0CC
X-Received: by 2002:a63:4a4d:: with SMTP id j13mr28887638pgl.127.1548871296290;
        Wed, 30 Jan 2019 10:01:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548871296; cv=none;
        d=google.com; s=arc-20160816;
        b=FC+99B0He0bE+4YBmYCxp19d2EBa2fcksMAn/PeTycvk6upCpibSHiRls1DowNOfiH
         D9bMW7mqn6ewxio2FOSlbOkpTaWDBMryAc4aAyiNi6pJ0z0pILnH5kvk9Z+heozSudGG
         otY+oJZAb73rD6GTcpW6CTulzpOrLWGXPE64fyqoIUoK5qFVsfwYnAqOPXIG5EoGRsWr
         xAUm9Ow0AI85vKpYTwbCxN2dLU7uygxfKXQ0RNvYIG3GzKcxGWTvit27g0BSB3O+6TW3
         QMnIjQrQDxXjGe1OEHXGMiGw7GcdqUfHhhfXyUCw9pM0jbcv+menPG5T0BzTyFTRk2pw
         lmRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=piRmYJDBFeS09Si2+LQuH+h2chqilpk+NrEIsPZRwPw=;
        b=lVpdpaVGZyNpbYjAhKmn2Fo9nvBfsOWJOznO5zXQht/L9rPuj3PBfjqF9T+ABJhrux
         Tv8HP023kfHGsTbvBVZWCPupY2q3n0GifStV0eNeYo97G5uZTBE1ak12cFfFTiu8FI9z
         naCOfhmefUtdhvSb6bPxiJTQQ76Nv+O0yIcsy9VOHELq1fDBkF8DCz03xXMVQMOJ4h/S
         /63IHTbfTaT6an0UjWTEbtMjz/jR2Jstoxj+JzGsZVOxTPCaLQSESNPcHt8UBO8sbsWz
         9270dagf9cydSr1ZXL5ySZm4HlcMUTKEF9pNfeu6wt8Cj+J7XoTy56Ws4Ly90qpQwZeQ
         Sigw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d125si1765008pgc.418.2019.01.30.10.01.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:01:36 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jan 2019 10:01:35 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,541,1539673200"; 
   d="scan'208";a="112386287"
Received: from fmsmsx104.amr.corp.intel.com ([10.18.124.202])
  by orsmga006.jf.intel.com with ESMTP; 30 Jan 2019 10:01:35 -0800
Received: from fmsmsx155.amr.corp.intel.com (10.18.116.71) by
 fmsmsx104.amr.corp.intel.com (10.18.124.202) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Wed, 30 Jan 2019 10:01:34 -0800
Received: from crsmsx152.amr.corp.intel.com (172.18.7.35) by
 FMSMSX155.amr.corp.intel.com (10.18.116.71) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Wed, 30 Jan 2019 10:01:34 -0800
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.57]) by
 CRSMSX152.amr.corp.intel.com ([169.254.5.81]) with mapi id 14.03.0415.000;
 Wed, 30 Jan 2019 12:01:33 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: 'Jason Gunthorpe' <jgg@ziepe.ca>
CC: Davidlohr Bueso <dave@stgolabs.net>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>,
	"jack@suse.de" <jack@suse.de>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, "Marciniszyn, Mike"
	<mike.marciniszyn@intel.com>, Davidlohr Bueso <dbueso@suse.de>
Subject: RE: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Thread-Topic: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Thread-Index: AQHUt2Gl37+5b+zRw0atYrNw3MHiB6XGEOqAgABlsYCAANFCgP//rILg
Date: Wed, 30 Jan 2019 18:01:33 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79BA6A27@CRSMSX101.amr.corp.intel.com>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-4-dave@stgolabs.net> <20190128233140.GA12530@ziepe.ca>
 <20190129044607.GL25106@ziepe.ca>
 <20190129185005.GC10129@iweiny-DESK2.sc.intel.com>
 <20190129231903.GA5352@ziepe.ca>
In-Reply-To: <20190129231903.GA5352@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMWIyZWE0MzUtMzA2OS00NmE5LTkyMDgtODAwZDFjNTRiZGMxIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoicmRSckVBakdiVzVYZ2k5Y3JFVCtETWc1Z2M4QWp1TFhLaVwvTmNnaXhjNXVYSW1hcGcrS0hDK2JGRFdYb2JpZVcifQ==
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
> On Tue, Jan 29, 2019 at 10:50:05AM -0800, Ira Weiny wrote:
> > > .. and I'm looking at some of the other conversions here.. *most
> > > likely* any caller that is manipulating rlimit for get_user_pages
> > > should really be calling get_user_pages_longterm, so they should not
> > > be converted to use _fast?
> >
> > Is this a question?  I'm not sure I understand the meaning here?
>=20
> More an invitation to disprove the statement

Generally I agree.  But would be best if we could get fast GUP for performa=
nce.  I have not worked out if that will be possible with the final "longte=
rm" solutions.

IRa

>=20
> Jason

