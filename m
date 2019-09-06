Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2417DC43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1E5320650
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:17:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1E5320650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C3126B000D; Fri,  6 Sep 2019 11:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 870DB6B000E; Fri,  6 Sep 2019 11:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75FAA6B0266; Fri,  6 Sep 2019 11:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id 520DF6B000D
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:17:39 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id F2F0B2DFE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:17:38 +0000 (UTC)
X-FDA: 75904850196.14.fly05_872977275661
X-HE-Tag: fly05_872977275661
X-Filterd-Recvd-Size: 1859
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:17:37 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C359E1596;
	Fri,  6 Sep 2019 08:17:36 -0700 (PDT)
Received: from [10.1.196.105] (unknown [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8F8623F59C;
	Fri,  6 Sep 2019 08:17:34 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: Re: [PATCH v3 03/17] arm64, hibernate: remove gotos in
 create_safe_exec_page
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: jmorris@namei.org, sashal@kernel.org, ebiederm@xmission.com,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org, corbet@lwn.net,
 catalin.marinas@arm.com, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, marc.zyngier@arm.com,
 vladimir.murzin@arm.com, matthias.bgg@gmail.com, bhsharma@redhat.com,
 linux-mm@kvack.org, mark.rutland@arm.com
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-4-pasha.tatashin@soleen.com>
Message-ID: <99aba737-a959-e352-74d8-a2aff3ae5a88@arm.com>
Date: Fri, 6 Sep 2019 16:17:33 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190821183204.23576-4-pasha.tatashin@soleen.com>
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
> Usually, gotos are used to handle cleanup after exception, but
> in case of create_safe_exec_page there are no clean-ups. So,
> simply return the errors directly.

Reviewed-by: James Morse <james.morse@arm.com>


Thanks,

James

