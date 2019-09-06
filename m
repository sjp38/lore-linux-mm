Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EBCCC00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:20:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D488220650
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:20:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D488220650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 870C06B000E; Fri,  6 Sep 2019 11:20:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8208E6B0266; Fri,  6 Sep 2019 11:20:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75DD26B026F; Fri,  6 Sep 2019 11:20:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id 539896B000E
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:20:32 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id F2BD0180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:20:31 +0000 (UTC)
X-FDA: 75904857462.09.songs16_21b715ad2be2a
X-HE-Tag: songs16_21b715ad2be2a
X-Filterd-Recvd-Size: 2085
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:20:31 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D76601576;
	Fri,  6 Sep 2019 08:20:30 -0700 (PDT)
Received: from [10.1.196.105] (unknown [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E23E83F59C;
	Fri,  6 Sep 2019 08:20:27 -0700 (PDT)
Subject: Re: [PATCH v3 09/17] arm64, trans_pgd: add trans_pgd_create_empty
To: Pavel Tatashin <pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-10-pasha.tatashin@soleen.com>
From: James Morse <james.morse@arm.com>
Cc: jmorris@namei.org, sashal@kernel.org, ebiederm@xmission.com,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org, corbet@lwn.net,
 catalin.marinas@arm.com, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, marc.zyngier@arm.com,
 vladimir.murzin@arm.com, matthias.bgg@gmail.com, bhsharma@redhat.com,
 linux-mm@kvack.org, mark.rutland@arm.com
Message-ID: <2d9f7511-ce65-d5ca-653e-f4d43994a32d@arm.com>
Date: Fri, 6 Sep 2019 16:20:26 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190821183204.23576-10-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

On 21/08/2019 19:31, Pavel Tatashin wrote:
> This functions returns a zeroed trans_pgd using the allocator that is
> specified in the info argument.
> 
> trans_pgds should be created by using this function.

This function takes the allocator you give it, and calls it once.

Given both users need one pgd, and have to provide the allocator, it seems strange that
they aren't trusted to call it.

I don't think this patch is necessary.

Let the caller pass in the pgd_t to the helpers.


Thanks,

James

