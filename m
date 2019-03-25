Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D08AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:28:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0648820830
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:28:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0648820830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 801D86B000A; Mon, 25 Mar 2019 10:28:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D6F36B000C; Mon, 25 Mar 2019 10:28:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C5D26B000D; Mon, 25 Mar 2019 10:28:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44EAD6B000A
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:28:06 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 35so10263965qty.12
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:28:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=LMBOMwxYbRsKP8okAy5V5c3pavZCJkJEXA7M7qzD2gE=;
        b=d7oF5RGBkZXh4ACHs+IDOOcEbvK0MRutPM+ZEKo4MYoGHRbKr1Efw7Io8NbhNlCS9n
         bz3lzt75259AEBADCZVigtmTcp7zh89/mbZQfJVvew3evlZLkcTLx25b2HyD++xKCgB+
         4qnoOZwLXAqX1R23mF5OI1GAqBVFRDf+sRw7VELLLcAdiNcZODPkqknni3uiNrNZJjO2
         CaOdkIalvGpmVCahY8Z5sQNxFaGsQBSJvZpzovCnyboecjEsYLVKonsq8tW13bAydRiZ
         a/F2ZsO7qf7JopQ7+Tdx9paYd+AW57UJHFnkx08xGZsdV0e15GilaPjvPqPBjOxeCE28
         MvyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXi4ENnagkcEoe42Nx0RChjXqvN03yq102btQRtQN6xhkOQgAwM
	XzJ4EAv2Kh8gD6Cok9T5iWJOicy9vtWDMDsU8tfOOPo8Sr1OaWzlPrvL0+r+BXq5dqWbp7MQ2jm
	u/zMYZQgS0i4GCJSuh6/YHh28VROL4IIxvb+UJ6DH1w/LyGhfJqyv3+YdqQ9KHD3QZA==
X-Received: by 2002:a37:6812:: with SMTP id d18mr20447422qkc.28.1553524086029;
        Mon, 25 Mar 2019 07:28:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTcfeSV+ZMr2RtCOquE3JUVziAA/8P3bKrUVvXNVIUOGPkap7oTSF3GZyP1WtGBzb8KR60
X-Received: by 2002:a37:6812:: with SMTP id d18mr20447390qkc.28.1553524085537;
        Mon, 25 Mar 2019 07:28:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524085; cv=none;
        d=google.com; s=arc-20160816;
        b=zgkFIImtK7cQ7KeZupGsOJiybyT9JZ5HqmCbGQPiQKH5XvmEDhFggmn02ZZYqRB2IQ
         3uVY49+zhPyC6YmIrxW33zFdNi851gST3jsh9FSGaG0ickeciwpcD+v62AN//HuelL88
         +FK1Dcdgx5KojCa8xUmvTY8ej0URrglqNpydA9ejeMRb5gU1E20Tq0mlNuUbybCcaBHa
         PxR0AMi2JxjU9A5xFa6v4dyo2vonA0E46XIqeV/QR1N5vqGwYPmki0HsEMWhauopDdBM
         SJJedrk+uDMdWO1tsB2hnhynf9vEb1LYkNmSXXHI65yOdsmCZ7p4gEIFNsb4+2xp75UF
         5D9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=LMBOMwxYbRsKP8okAy5V5c3pavZCJkJEXA7M7qzD2gE=;
        b=aCUUgm+nFC3vBX2rCBTOYQ/2Y072gABC0OBoiBNZe1FgTUUYyfsWP6YgNz7qs9dL4n
         cXa3F3yJSe68QYo2Rf+2CIVLTeXGwGU8lJVyUiGdMjj4ufZ+JltNrvUpew8HyXfdE0sk
         MqwSEUFzdBrv0isT0QeXvQ3kvNV7+w0VLBo3TnDx5unSVP5wraC+QpYpKk5uacLkzHOK
         sFytGs7HTh81oZJQ9/E1MCmexlmJdTkAgZpnjcL8zXkqF+czwbJJue5MgLLm+HIYXd34
         UxVycHvRPYK7cR0PClbez54pin1mp+UpVv0P752dCg1y4MHsDPTNc4w4FJALSMBZqYUY
         aMvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m10si1332766qkg.37.2019.03.25.07.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:28:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9480288304;
	Mon, 25 Mar 2019 14:28:04 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 729CC842B2;
	Mon, 25 Mar 2019 14:28:02 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>,  Andrew Morton
 <akpm@linux-foundation.org>,  =?utf-8?B?SsOpcsO0bWU=?= Glisse
 <jglisse@redhat.com>,  Logan Gunthorpe <logang@deltatee.com>,  Toshi Kani
 <toshi.kani@hpe.com>,  Vlastimil Babka <vbabka@suse.cz>,  stable
 <stable@vger.kernel.org>,  Linux MM <linux-mm@kvack.org>,  linux-nvdimm
 <linux-nvdimm@lists.01.org>,  Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20190322180532.GM32418@dhcp22.suse.cz>
	<CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
	<20190325101945.GD9924@dhcp22.suse.cz>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Mon, 25 Mar 2019 10:28:00 -0400
In-Reply-To: <20190325101945.GD9924@dhcp22.suse.cz> (Michal Hocko's message of
	"Mon, 25 Mar 2019 11:19:45 +0100")
Message-ID: <x494l7rdo5r.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 25 Mar 2019 14:28:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko <mhocko@kernel.org> writes:

>> > and I would like to know that you are
>> > not just shifting the problem to a smaller unit and a new/creative HW
>> > will force us to go even more complicated.
>> 
>> HW will not do this to us. It's software that has the problem.
>> Namespace creation is unnecessarily constrained to 128MB alignment.
>
> And why is that a problem? A lack of documentation that this is a
> requirement? Something will not work with a larger alignment? Someting
> else?

See this email for one user-visible problem:
  https://lore.kernel.org/lkml/x49imxbx22d.fsf@segfault.boston.devel.redhat.com/

Cheers,
Jeff

