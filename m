Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEAF4C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 08:40:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70EB42173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 08:40:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70EB42173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axis.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9A078E0003; Tue, 26 Feb 2019 03:40:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E48B48E0002; Tue, 26 Feb 2019 03:40:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D37F78E0003; Tue, 26 Feb 2019 03:40:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62E108E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:40:38 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id n25so2267157lfe.15
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:40:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=bTHWu/kC06ZN3NlbrciXaxQEcXqgdu17tqMpiGLkGF4=;
        b=QlTnD4f0cq7AkLHkHkoXF20iBi1y2OKv6T1L4HPwjgq98GpWGasAYdSxSgP+Rw4k7P
         1M9y1yuqqwFOMEPmUyG3s9esTsOSFmnyE5GgFCp/Ue+ktcemUymm5H4omws3asJwRmgW
         iPVRFHO81FOFL7gz8h3by20S08Bx2rEGKYjElptmEYCyWJmBMM2SO6p+SEleqL5a5nlL
         TtYVSyP9N8+49pwzFYC5DDNCcNOaaNXY+bbmLJS/IJyQKEpOKBYfaUGitcDVJZuaTzDT
         gV0LC9CPJrdOktQodDLCYne7yr7WfPPmpaXn1K9oHfj4hLvc4IdEcPDWeCCtBCwaByWW
         Y2sA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
X-Gm-Message-State: AHQUAuZ9zoVmzgFagPBL9TiK/h31rkpc9rO3fPpt5NF+s5nrMWI9Zl3t
	L1QDuzhoOokMEnGSP44ZxrKHcKBdjVdgp1VTN6+lPKMsILKetb+zcB0VdUYTUfXID1E2hafLZjc
	KbN8SwroAUqD9p+bIPiI5Gsg6Q3uyW/uDns/0TY2ymwGTbMO3Gsa6sW/+K+whDL/SoA==
X-Received: by 2002:a2e:96c9:: with SMTP id d9mr12204438ljj.133.1551170437586;
        Tue, 26 Feb 2019 00:40:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY2CjNZ7pOTXJhE06eHv275EI61VgL/kKpmS2RSQKlIGVv37Bala1MCDCE6yRHaXNKHPX/G
X-Received: by 2002:a2e:96c9:: with SMTP id d9mr12204393ljj.133.1551170436520;
        Tue, 26 Feb 2019 00:40:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551170436; cv=none;
        d=google.com; s=arc-20160816;
        b=ZsbV9a5FJCqCn9l1PrQUU5SeK3W6htSeqS0FXwUWfUbUJv2PbHfoViRyN/mfk1cL0A
         seslSLMKHIXgMQr2KTeJHB72ALxFfoQyO40pdQPiUB9X/8CLXeJcHSLRBCDXmzIygZ3A
         D9COr7xmQsYB3KT8ZAm+m1yR5Wt0BbfyYJGXWxEisz25Jyt/7i/sCuPNs1CrzWM5YhB7
         6XC6t9SV9x8w/i5rVtX4pvMfASSrEzUcpMUaEgw8XExBRzcO8O2aa0yzY7Z6+NddupIc
         LgL3LHeFt7oob/ht6uCfkpDxO+TQ7KuGSzFTcFnXtKFi8WtnkTjxLUaq9Oma35NyudoW
         MjdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=bTHWu/kC06ZN3NlbrciXaxQEcXqgdu17tqMpiGLkGF4=;
        b=Ttn/GnyN4DKkqlNIt3ik8sv+Qoaiqo8l1KjIzd07JBVIUAHlwVOB5bA7lRyjWOMufh
         a+n6PYgt7s6NOMejBQFpGMIn+htPg8xEWge36RdXnC6OVVimvEaSUXEdTzt5dvLscOUl
         wzcyz4CHzC9GnTjrUwR+3oQ99wFToiyfkxbRdFdQtPDDYU/YajK6AMjt2mlCbk7gNFjD
         OWapiNE5KE8+MU0I2jYVXmvUxXpn+ZJM4lXeacwGLBImMfnsGYtPXLKveAJSsAe/3SJ1
         r1n230N5bVjPTH8rlmumplckQkkyoMWPn5YrjDShpBjKZe09d8VzG+t3N+tv+zr4lrqq
         pImA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id q13si8064401lfb.127.2019.02.26.00.40.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 00:40:36 -0800 (PST)
Received-SPF: pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) client-ip=195.60.68.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from localhost (localhost [127.0.0.1])
	by bastet.se.axis.com (Postfix) with ESMTP id C57BF184A3;
	Tue, 26 Feb 2019 09:40:35 +0100 (CET)
X-Axis-User: NO
X-Axis-NonUser: YES
X-Virus-Scanned: Debian amavisd-new at bastet.se.axis.com
Received: from bastet.se.axis.com ([IPv6:::ffff:127.0.0.1])
	by localhost (bastet.se.axis.com [::ffff:127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id YPknBDMvn3gz; Tue, 26 Feb 2019 09:40:35 +0100 (CET)
Received: from boulder02.se.axis.com (boulder02.se.axis.com [10.0.8.16])
	by bastet.se.axis.com (Postfix) with ESMTPS id F2B6518470;
	Tue, 26 Feb 2019 09:40:34 +0100 (CET)
Received: from boulder02.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C60061A07C;
	Tue, 26 Feb 2019 09:40:34 +0100 (CET)
Received: from boulder02.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BAD2E1A07B;
	Tue, 26 Feb 2019 09:40:34 +0100 (CET)
Received: from thoth.se.axis.com (unknown [10.0.2.173])
	by boulder02.se.axis.com (Postfix) with ESMTP;
	Tue, 26 Feb 2019 09:40:34 +0100 (CET)
Received: from XBOX04.axis.com (xbox04.axis.com [10.0.5.18])
	by thoth.se.axis.com (Postfix) with ESMTP id AE73722F;
	Tue, 26 Feb 2019 09:40:34 +0100 (CET)
Received: from [10.88.41.2] (10.0.5.60) by XBOX04.axis.com (10.0.5.18) with
 Microsoft SMTP Server (TLS) id 15.0.1365.1; Tue, 26 Feb 2019 09:40:34 +0100
Subject: Re: [PATCH] mm: migrate: add missing flush_dcache_page for non-mapped
 page migrate
To: Vlastimil Babka <vbabka@suse.cz>, Lars Persson <larper@axis.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
CC: <linux-mips@vger.kernel.org>
References: <20190219123212.29838-1-larper@axis.com>
 <65ed6463-b61f-81ff-4fcc-27f4071a28da@suse.cz>
From: Lars Persson <lars.persson@axis.com>
Message-ID: <ed4dd065-5e1b-dc20-2778-6d0a727914a8@axis.com>
Date: Tue, 26 Feb 2019 09:40:30 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <65ed6463-b61f-81ff-4fcc-27f4071a28da@suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: sv
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: XBOX03.axis.com (10.0.5.17) To XBOX04.axis.com (10.0.5.18)
X-TM-AS-GCONF: 00
X-Bogosity: Ham, tests=bogofilter, spamicity=0.029567, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/25/19 4:07 PM, Vlastimil Babka wrote:
> On 2/19/19 1:32 PM, Lars Persson wrote:
>> Our MIPS 1004Kc SoCs were seeing random userspace crashes with SIGILL
>> and SIGSEGV that could not be traced back to a userspace code
>> bug. They had all the magic signs of an I/D cache coherency issue.
>>
>> Now recently we noticed that the /proc/sys/vm/compact_memory interface
>> was quite efficient at provoking this class of userspace crashes.
>>
>> Studying the code in mm/migrate.c there is a distinction made between
>> migrating a page that is mapped at the instant of migration and one
>> that is not mapped. Our problem turned out to be the non-mapped pages.
>>
>> For the non-mapped page the code performs a copy of the page content
>> and all relevant meta-data of the page without doing the required
>> D-cache maintenance. This leaves dirty data in the D-cache of the CPU
>> and on the 1004K cores this data is not visible to the I-cache. A
>> subsequent page-fault that triggers a mapping of the page will happily
>> serve the process with potentially stale code.
>>
>> What about ARM then, this bug should have seen greater exposure? Well
>> ARM became immune to this flaw back in 2010, see commit c01778001a4f
>> ("ARM: 6379/1: Assume new page cache pages have dirty D-cache").
>>
>> My proposed fix moves the D-cache maintenance inside move_to_new_page
>> to make it common for both cases.
>>
>> Signed-off-by: Lars Persson <larper@axis.com>
> 
> What about CC stable and a Fixes tag, would it be applicable here?
> 

Yes this is candidate for stable so let's add:
Cc: <stable@vger.kernel.org>

I do not find a good candidate for a Fixes tag.

