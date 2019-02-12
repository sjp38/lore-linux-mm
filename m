Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 851FAC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:35:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ADDE206A3
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:35:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ADDE206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD1B48E01A0; Mon, 11 Feb 2019 19:35:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C818F8E019C; Mon, 11 Feb 2019 19:35:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B24228E01A0; Mon, 11 Feb 2019 19:35:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1448E019C
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:35:13 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o62so654712pga.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:35:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=d/bbpNybwqlafvtu1wi2MT1eS0FvpwuJQfeJ2QoYO2I=;
        b=DkglFI60iH10ZWMj0SJtehRRMp/taoRJ6ia7AbkDX52cg5HdLgmqgNYbuOSHLOd3Mv
         vqDMzsH7D64rYb90VVV+GD2+zMvm3+pOUpb4bREm+mssCyvbbfkVy48frKAHnWnIh55i
         9WE1y38n9B0JG1WNNV7l3ZDF31g+W+m0R/YTLuCPhOxT2huUyiVGa2wP/vkiyfYenxDK
         MHTjTV3dKPVdleDkh2UwRpAQtBYgwcUxOXLtHzzMVCjxOFb5ye3JtQIGb7YRwRb7g6cx
         Vddy45X7f0564c0oyyVo2vjQz2+1IJYEWQX1lG7s0jm7GOAdQaaAWaBtnJ9L2QCMzCKf
         b2Yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubTFjLv3zAVn7lKC1EPZ9YxlcvBggX2/JCtDAYCXY7xL0yDx9w6
	cv34EuicgMl/3Vx49HSZcSj9oQymHEZgpBGSKWW3eX1CoiQ/ELSNbheU8iUXXaI7pszVhVRxLQ1
	vCbTSphuEET6ei6GkzxQacJB9wP0bpAOKn80DY3JLGL6sbtC4snaO/IU9/DY14DQRLw==
X-Received: by 2002:a62:190e:: with SMTP id 14mr1110139pfz.70.1549931713128;
        Mon, 11 Feb 2019 16:35:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbhXkPPEM1xcgs2th1I9cHA4NCVktq5hkBbTAkBz6TzNsQF5xHFgs80scsNERZlFcM5tn4x
X-Received: by 2002:a62:190e:: with SMTP id 14mr1110094pfz.70.1549931712431;
        Mon, 11 Feb 2019 16:35:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549931712; cv=none;
        d=google.com; s=arc-20160816;
        b=m7Hx95akarz7sm8+5nC5eqPo+KTWZ/gTO7hCl0q72vArno6F95HlLJtwfdN3SZU5gd
         fmCxn51CVu+OTo0QjLj191Cm2j9jgVr0ecdM5B+U4YJMgOHLQmTubqa0kAfYTrXsd62v
         5Kgf2mbyT+QPn4Vf8W4m8JSyMNVgFkhVdEn0PLaoQqhvJSDj7TmCFNlmvPHAAtGHiH1o
         0izdqxogNwe/ZNJPHDmKcczBq3bxsHjg3ZCnlzUsEJpsbqPx0yrark5xfeGnkHA4OCZO
         5AA7ZPWHQ27Pb+cSOsgfxPS174dkYSx7+gR3XUypGjL6KYe+hKPpquUI8Ov6jSfFvFPl
         53+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=d/bbpNybwqlafvtu1wi2MT1eS0FvpwuJQfeJ2QoYO2I=;
        b=vGn4t91H8qDWjSFZn+kcen6OzTYIJlY3kOkOf8iFBdKeOavlkZ0nFe9YQEqJ1GClyc
         w/TTCFSZfPZqPJ3BCJSblFPtMHeG0tr8fDrmaoJrHQSApeKBXfVSTo40Cx+DbRLVsPVe
         g9PMeaOLo26NyPCce7U4UZ9GIaOwu6F5hIQrT2kdTQMURPWcKaQOr9+MehmoEdMjaxx/
         L3uXAfa0uxvcJh7ZfIR6NRHmSyqTNTqVoyIW4lKpTxSwVpcjsbp1rQmqTtTkTyW+irYr
         Q3asI5APkD+H8eRiaws+EeoO8f+FsLOR7+Nsp0zMERJ85frU+iFdCuefgXje62L/JDnl
         dZ5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g11si11559186pgn.32.2019.02.11.16.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 16:35:12 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 16:35:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="318189983"
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by fmsmga006.fm.intel.com with ESMTP; 11 Feb 2019 16:35:11 -0800
Received: from fmsmsx157.amr.corp.intel.com (10.18.116.73) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 16:35:11 -0800
Received: from crsmsx103.amr.corp.intel.com (172.18.63.31) by
 FMSMSX157.amr.corp.intel.com (10.18.116.73) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 16:35:11 -0800
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.57]) by
 CRSMSX103.amr.corp.intel.com ([169.254.4.180]) with mapi id 14.03.0415.000;
 Mon, 11 Feb 2019 18:35:09 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Davidlohr Bueso <dave@stgolabs.net>, "jgg@ziepe.ca" <jgg@ziepe.ca>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
CC: "dledford@redhat.com" <dledford@redhat.com>, "jgg@mellanox.com"
	<jgg@mellanox.com>, "jack@suse.cz" <jack@suse.cz>, "willy@infradead.org"
	<willy@infradead.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 7/6] Documentation/infiniband: update from locked to
 pinned_vm
Thread-Topic: [PATCH 7/6] Documentation/infiniband: update from locked to
 pinned_vm
Thread-Index: AQHUvoT55Uy7G877J0q1705BUMR+vKXbWG0A
Date: Tue, 12 Feb 2019 00:35:08 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79BCF60F@CRSMSX101.amr.corp.intel.com>
References: <20190206175920.31082-1-dave@stgolabs.net>
 <20190207013155.lq5diwqc2svyt3t3@linux-r8p5>
In-Reply-To: <20190207013155.lq5diwqc2svyt3t3@linux-r8p5>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNzcxNjc5YjktMWQzNC00MTc0LTgwNTAtNzBhOGM3YWZiZTIyIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoienppekg3cjdhNlpkTGlmOVF1c1JWXC9QamsrbjlLQ1ZTWStKcnhXSTR1WE5Jc2FvZ2lHNDUrWkRCTEtcLytQUERcLyJ9
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

> -----Original Message-----
> From: Davidlohr Bueso [mailto:dave@stgolabs.net]
> Sent: Wednesday, February 06, 2019 5:32 PM
> To: jgg@ziepe.ca; akpm@linux-foundation.org
> Cc: dledford@redhat.com; jgg@mellanox.com; jack@suse.cz;
> willy@infradead.org; Weiny, Ira <ira.weiny@intel.com>; linux-
> rdma@vger.kernel.org; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: [PATCH 7/6] Documentation/infiniband: update from locked to
> pinned_vm
>=20
> We are really talking about pinned_vm here.
>=20
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  Documentation/infiniband/user_verbs.txt | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/Documentation/infiniband/user_verbs.txt
> b/Documentation/infiniband/user_verbs.txt
> index df049b9f5b6e..47ebf2f80b2b 100644
> --- a/Documentation/infiniband/user_verbs.txt
> +++ b/Documentation/infiniband/user_verbs.txt
> @@ -46,11 +46,11 @@ Memory pinning
>    I/O targets be kept resident at the same physical address.  The
>    ib_uverbs module manages pinning and unpinning memory regions via
>    get_user_pages() and put_page() calls.  It also accounts for the
> -  amount of memory pinned in the process's locked_vm, and checks that
> +  amount of memory pinned in the process's pinned_vm, and checks that
>    unprivileged processes do not exceed their RLIMIT_MEMLOCK limit.
>=20
>    Pages that are pinned multiple times are counted each time they are
> -  pinned, so the value of locked_vm may be an overestimate of the
> +  pinned, so the value of pinned_vm may be an overestimate of the
>    number of pages pinned by a process.
>=20
>  /dev files
> --
> 2.16.4

