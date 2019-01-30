Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAD9CC282D5
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:23:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 942542087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 08:23:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 942542087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=il.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 320E48E0005; Wed, 30 Jan 2019 03:23:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D15F8E0001; Wed, 30 Jan 2019 03:23:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C1608E0005; Wed, 30 Jan 2019 03:23:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC7AF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:23:10 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so15780519pgt.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 00:23:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:in-reply-to:to
         :cc:subject:from:date:references:mime-version:message-id
         :content-transfer-encoding;
        bh=QWLhIdER7CjaHfw9YFQlbX7bsGUCA5ioqw0ziKDtBD4=;
        b=XL2IwVvA5onE4z/dFnEhqGUvYSwGPEzrBBa+HksMosZqdqI2r64+OlIpV7pAk5TrWl
         at6ooMSvbMsnvt/6jHLr48gj7RVELLs4s5rixhqllBLQcqS2YyL4xnjU7QTQvzDffgHL
         eWDXWHKNwAqWWbzqYgr+fK0Fl4IrK6jFsJpv3hhAFclfsE90WS4/a2t/YZjGjNxWG4kx
         izvgOGqthAik5e0vc6ko+pPrNq5FpDW+Gh7OCtDHTFxWEgBknBy79aXvQLG8iqaz/BXe
         sZv/N8DLdjOXcKyQqEXU41yr0s17fDjbOQpLigAD+CS/4FudOoMwEJZ/g2AQLEZI1R8v
         uA7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=JOELN@il.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUuke/DjzTcN3OneaXSY9yfv24QyiPWNLNil7nrB7+/Mnow0tTMqBj
	v3UWq2/zTbOZgnQAhctIkNubk+/gY76ahzfh9qRTOJ9RT+fpVfI0iMvAWLxp4dIY9EBBHXFaZ2r
	/LyWmi5iDpLZG5zayrBO2IDhzk4DsyaREx/strUjjsy7daBpLnhBW+ykuk5LRYw2v0A==
X-Received: by 2002:a17:902:1102:: with SMTP id d2mr29535176pla.138.1548836590431;
        Wed, 30 Jan 2019 00:23:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN76pjYaH4REn3Rz4Jcj6EeOU0MoDAl8Kipjehak0MF9dsdgcBbV1Jnkd08bNu4ROXylqJh7
X-Received: by 2002:a17:902:1102:: with SMTP id d2mr29535159pla.138.1548836589807;
        Wed, 30 Jan 2019 00:23:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548836589; cv=none;
        d=google.com; s=arc-20160816;
        b=KfjtqR/RbZxPKGrQg9Viu+GchXG9QBTjCDX+wYvAGnYj2nogXfuxt42acyKD6P+ktN
         9rJ1UkD9Oxa17jFh0mWGRF/LwIX2zr5AUdHyzsZsGa6fDSLaoa8SpT2sahZceZGQQKCZ
         LX1ICTOr12svPyaT87+zRYk+HUkFcWCvAg3AWGApHnxjHlyobxUNnJTU3HosYq3SqYtU
         XkvkJsCdoAEwwjPz02lX1VS/22S9qQ3rAfGyW/kVxgVyhswoUO/olJV299JYYsixcrSU
         cS8hDPmbVU8X3JvBzaKWXfANC+VBpftAiXGpV3b7ZSVERQy+QqFBuk+8rC1PWGihfihM
         +veQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:mime-version:references:date
         :from:subject:cc:to:in-reply-to;
        bh=QWLhIdER7CjaHfw9YFQlbX7bsGUCA5ioqw0ziKDtBD4=;
        b=TPm9OIU9GkYb3RCyN2/YmM4AbShhhdfuxV04EGtf9cG3+5tgLLOtuLBVkioF6/bQmT
         5Z0Y/cKYk8rLWsfDgxhvSYcs1I5AftYNuYrmFQIq4z0AvQwuca6wxyrwtFDW5FbajaT7
         Dt0rKVOWvp3+ViXCi125UBBzcowQRCOXketP8XVyO3lnKXl/uyWPjApf/4Xqq4ARyZv+
         pldODbSbcZFdwrvfJEYTAZViN3Z5dOBsFdx1LV9nAwTXOOparNJjBEvhRGglp+Z4MLct
         Kf+IR7x2MKrgfki4pGi6QJvVLbu4xVUmO1NT61GfqAKys1WSX3dlH/FsjubaWAEMcZ1A
         MMHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=JOELN@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u21si878321pgm.21.2019.01.30.00.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 00:23:09 -0800 (PST)
Received-SPF: pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=JOELN@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0U8Jktc144319
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:23:09 -0500
Received: from smtp.notes.na.collabserv.com (smtp.notes.na.collabserv.com [192.155.248.81])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qb6h5mv7h-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:23:09 -0500
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-mm@kvack.org> from <JOELN@il.ibm.com>;
	Wed, 30 Jan 2019 08:23:08 -0000
Received: from us1a3-smtp02.a3.dal06.isc4sb.com (10.106.154.159)
	by smtp.notes.na.collabserv.com (10.106.227.88) with smtp.notes.na.collabserv.com ESMTP;
	Wed, 30 Jan 2019 08:23:00 -0000
Received: from us1a3-mail108.a3.dal06.isc4sb.com ([10.146.45.126])
          by us1a3-smtp02.a3.dal06.isc4sb.com
          with ESMTP id 2019013008225964-212703 ;
          Wed, 30 Jan 2019 08:22:59 +0000 
In-Reply-To: <8cdb77b6-c160-81d0-62be-5bbf84a98d69@opengridcomputing.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        Leon
 Romanovsky
 <leon@kernel.org>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-rdma@vger.kernel.org,
        Mike
 Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 0/5] RDMA: reg_remote_mr
From: "Joel Nider" <JOELN@il.ibm.com>
Date: Wed, 30 Jan 2019 10:22:59 +0200
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
 <8cdb77b6-c160-81d0-62be-5bbf84a98d69@opengridcomputing.com>
MIME-Version: 1.0
X-KeepSent: 3A13C355:FCBF3024-C2258392:002D8AC7;
 type=4; name=$KeepSent
X-Mailer: IBM Notes Release 9.0.1FP7 August 18, 2016
X-LLNOutbound: False
X-Disclaimed: 19363
X-TNEFEvaluated: 1
x-cbid: 19013008-7093-0000-0000-000009FC1B6E
X-IBM-SpamModules-Scores: BY=0; FL=0; FP=0; FZ=0; HX=0; KW=0; PH=0;
 SC=0.425523; ST=0; TS=0; UL=0; ISC=; MB=0.235916
X-IBM-SpamModules-Versions: BY=3.00010503; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000277; SDB=6.01153828; UDB=6.00601586; IPR=6.00934202;
 BA=6.00006216; NDR=6.00000001; ZLA=6.00000005; ZF=6.00000009; ZB=6.00000000;
 ZP=6.00000000; ZH=6.00000000; ZU=6.00000002; MB=3.00025352; XFM=3.00000015;
 UTC=2019-01-30 08:23:06
X-IBM-AV-DETECTION: SAVI=unsuspicious REMOTE=unsuspicious XFE=unused
X-IBM-AV-VERSION: SAVI=2019-01-30 06:41:57 - 6.00009527
x-cbparentid: 19013008-7094-0000-0000-0000706E1CC0
Message-Id: <OF3A13C355.FCBF3024-ONC2258392.002D8AC7-C2258392.002E0D17@notes.na.collabserv.com>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_07:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Steve Wise <swise@opengridcomputing.com> wrote on 01/29/2019 06:44:48 PM:

>=20
> On 1/29/2019 7:26 AM, Joel Nider wrote:
> > As discussed at LPC'18, there is a need to be able to register a=20
memory
> > region (MR) on behalf of another process. One example is the case of
> > post-copy container migration, in which CRIU is responsible for=20
setting
> > up the migration, but the contents of the memory are from the=20
migrating
> > process. In this case, we want all RDMA READ requests to be served by
> > the address space of the migration process directly (not by CRIU).=20
This
> > patchset implements a new uverbs command which allows an application=20
to
> > register a memory region in the address space of another process.
>=20
> Hey Joel,
>=20
> Dumb question:
>=20
> Doesn't this open a security hole by allowing any process to register
> memory in any other process?

Not a dumb question - there is a security problem. Jason just suggested
I look at how ptrace solves the problem, so that's my best option at the
moment. Still, I figured it was a good idea to let everyone take a look
at what I have so far, and start to get feedback.

> Steve.
>=20
>=20


