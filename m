Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95BFDC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:40:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48DA0217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:40:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="cv74FdRv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48DA0217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDA158E00CF; Wed,  6 Feb 2019 15:40:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B89948E00CE; Wed,  6 Feb 2019 15:40:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A77ED8E00CF; Wed,  6 Feb 2019 15:40:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7ABB48E00CE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:40:00 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 207so7617062qkl.2
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:40:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=R2KDuPlwpmsOkmArWTw0n8mPtdrOEQWijHDLdwtjpgs=;
        b=NrI3hIcxVyBg75ZY/pVG6YwyGlXrj/2uMjvrN99qcyRbSjZ9oGZIVLLcdIK/vMr77j
         642fSEDeE7aZDoFSSH0sV6NTFiGN3b5DBXppmkufMkBUHs9svssidlCVL9qrs4IGwmjS
         cuoaGFv0vwtwXkFy7aJJQoOFNqBc8YyPVAUU5fRdtdiJfosX7z49F3nZt07L9/6kEc07
         ZhT2E2QtPl+zcqdViAXpH9Y78UwPv/NYyJss9H+P8c8swxLrf5OSRuOs7GNHMA9VFzgA
         WL2qekCvwBbmxvgD0ZdiGBjvUfDoUE93tAb9MROLIAQZfvd4TYDKfntyfBfjeCDmJlp7
         xeSg==
X-Gm-Message-State: AHQUAubczMQ5RF0a0dI31xcuV9mtexAMJi4OgqgTC+lCbtnIjzwgQh4o
	XnBtDQ9HV1biks9mT5/mbeHW+FkhvpvNP0jS/6iEHyLocXxpr4kV6gYPruhqO+U5hfeFvr0UhbB
	3ns+s6Nc/Z/GPw9A/9nkpZxMivFZVZwwtD5MINXT4fX/TSGO3NGa1Ge/L5tjxMRM=
X-Received: by 2002:a0c:f8cb:: with SMTP id h11mr9388575qvo.134.1549485600276;
        Wed, 06 Feb 2019 12:40:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafwPKPuzky/fiBqIqLSavOD/F0vfoAmdFOXeatnEEzUh0D4sRr9/5ewsHluSWDGyQrsiKn
X-Received: by 2002:a0c:f8cb:: with SMTP id h11mr9388542qvo.134.1549485599683;
        Wed, 06 Feb 2019 12:39:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549485599; cv=none;
        d=google.com; s=arc-20160816;
        b=dGdu2ANZkOVgBqUfxtDUONh+Oygof8LER98ypf1568S1pbWjMLEfMQnGMKiP0XgU+8
         hCka2il8a4XlPavmSfx9ehsztKTbL1pNBlOw2W2IgzUieYKS+68QlawKGqKNMgJ8zBkL
         lWDf9WPyk67csmNYtIsjVZ7x1zKgHkZ6PG3SeVyo4Br0HBLLLKlWVPLpgiISarfBbh96
         R4ZZPWMssBy0hovcAinXYEl2NQ34eNhOgVf2yEILuiMPI6zgR+ChSXPcUVJTuEaEts2N
         /iFCxBc6A767qrZ8a2Ls8fTnPBvZKqsLQSc3EFG4ciArmkZQo0MRRaBSjrD0o4KrdjKI
         hdIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=R2KDuPlwpmsOkmArWTw0n8mPtdrOEQWijHDLdwtjpgs=;
        b=im1uKcP4c2o05hMnOuTmpqLYlDOLumRzV4nc3IR0aJyQyB2FCdVBE+kDT7BLthbtCN
         fM+8VRYXDvH6OxB677bucbUHXIfQcuDmCCg7f/VBmTh4W3Qsj/3n3Ka0sFStW5GTWhFJ
         9FEyuTAREmIc0BnTOtzhWHFuj0kurX+J8OeV0Kbebnyl5QU+xmUhU4gOtIUW+JDaS+nj
         mrXARPGC8PdsHytm1jL0e8T85EUSAamCo+K0pw/L2yKgWl3sc4nnUm5gafPn5U8ykn9w
         ojZZQntmwkYo7uQusk6+Bn4tJlugE9UlNC+XAluwIddeDoJDFIdbjPAIdeEwxbO09YZD
         r8ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=cv74FdRv;
       spf=pass (google.com: domain of 01000168c489e945-b34792be-adb9-44ce-b7a3-83d9232848c1-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000168c489e945-b34792be-adb9-44ce-b7a3-83d9232848c1-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id i2si1471439qkd.137.2019.02.06.12.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 12:39:59 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168c489e945-b34792be-adb9-44ce-b7a3-83d9232848c1-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=cv74FdRv;
       spf=pass (google.com: domain of 01000168c489e945-b34792be-adb9-44ce-b7a3-83d9232848c1-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000168c489e945-b34792be-adb9-44ce-b7a3-83d9232848c1-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549485599;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=KCnUJlwQKrPyUUqRPNg3t9cL/cv5MgY2z3DU/pPTaqc=;
	b=cv74FdRvic7TI9m6xRCUtxP6ud5qi2iADMgwmPf2CPD4JZONmsdNN8aMKlS1ZDCg
	EjPx8+q7zsXPmP0+GM10VSu1+xf6UzXHgRGO/SgI3g8i/TsHOsfuR/+wqLBIZ3s8iaJ
	BlbOoVWBBlE9J2mOS4mq4qPUHB8t0VUts7llH+W8=
Date: Wed, 6 Feb 2019 20:39:59 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Wilcox <willy@infradead.org>
cc: Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>, 
    lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <20190206202021.GQ21860@bombadil.infradead.org>
Message-ID: <01000168c489e945-b34792be-adb9-44ce-b7a3-83d9232848c1-000000@email.amazonses.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com> <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca> <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com> <20190206194055.GP21860@bombadil.infradead.org> <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com> <20190206202021.GQ21860@bombadil.infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.06-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2019, Matthew Wilcox wrote:

> It's straightforward to migrate text pages from one DIMM to another;
> you remove the PTEs from the CPU's page tables, copy the data over and
> pagefaults put the new PTEs in place.  We don't have a way to do similar
> things to an RDMA device, do we?

We have MMU notifier callbacks that can tell the device to release the
mappings. And an RDMA device may operate in ODP mode which is on demand
paging. With that data may be migrated as usual.


