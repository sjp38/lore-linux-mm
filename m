Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 105FEC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:20:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B96282084D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:20:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="GWhicdJz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B96282084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43A6A6B0007; Thu, 13 Jun 2019 03:20:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EBFD6B000A; Thu, 13 Jun 2019 03:20:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DA546B000C; Thu, 13 Jun 2019 03:20:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 074DD6B0007
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:20:49 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c207so12457557qkb.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:20:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=dhmXrepDAZcjXkpQs5VfxOBzitc3aINuYRH8cXmOgbc=;
        b=NDvI9E21RuZVqHFsH4Ocz1vpJRSOQCHMRLqUKH4xeRYMtl4MPDtWZ+Am2DDZHmA2/4
         DEOITskSNlu0hxc4mZupR0M9abO1+7z/9vHUJPCDHMo9FWr7k3JvpR1zy0sIukYlGGKx
         5wnQ4iCLr4MH7m0wIMKCxbtOR6GWZMq/0wtP1mE/Ez674ITy3DHkk5bCCRU1m6mfoACl
         UL+sRIfQswE3y4o7A7PXrbrhWMjJ3pe8XtsnEDudLUrNSvmo8qTdc+kOupY0t7qMquzI
         gzx2cCIKtWqa+bdh6HW+/2fW2Dt3ePQYdDFiPd4TmKc8SUKx0NgNbRDQda4w7et7ObY0
         40xA==
X-Gm-Message-State: APjAAAUyCaOR34Yh5HWI9SbJHmApkn0P9bXyu6MLrJm5LXWIziL19rOk
	+CDZnq5IB8cQnXVIAS3hERhACMU160ZpXumwKQbM5GDNiWv+Anz3tmVM/Kvwg2SQzp56Q7ZMFAt
	DFphvOYgwuuj9blSLLvDtIUsksl7MMkrUK7VgVJWLyxNz6kr7wSOTce63eHp7EjFgHQ==
X-Received: by 2002:a37:aa0d:: with SMTP id t13mr69001748qke.167.1560410448707;
        Thu, 13 Jun 2019 00:20:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqza4yd4oR461SU1aifIwMs4rHlieETeIvd14YDDcfzXtnjBHOYY7ynwWXEdsE6Yo8Imyv5f
X-Received: by 2002:a37:aa0d:: with SMTP id t13mr69001702qke.167.1560410448198;
        Thu, 13 Jun 2019 00:20:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560410448; cv=none;
        d=google.com; s=arc-20160816;
        b=ddnrvydO3l/muweQKYLvnl5QSOEWOuEIBStCubqKgzdpVMWBsGgcesF28M2BH6JVXM
         cTQjF6/lv4ESAK3ttXN8GTBxK6UmcFnOg67TV1wCsHH0L4yAdYCsPb5ttEonXar/IxZt
         IxUCYw9szGCNnUrY+aOGk7B5yiGljuDmMdevm8rXJ58AQDGq7nk6G8FONUZcdmjo1I6U
         +V/gIHIkcyZb5q5iAbJZYUPg2hXAEySHRW45ytH7uGLcWXjltDV63EE7GGCf51VKIT49
         zcAlNVnH4xTMOa3HaGArvjuyrG7QOdKAO/Hh3cRVgweD/EB4wzu/GS0QO04EZ/yMbs93
         PBEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=dhmXrepDAZcjXkpQs5VfxOBzitc3aINuYRH8cXmOgbc=;
        b=ssUrmSNiIPEu2NQIKE5tcvsO0jRdcLr5iSrh3+dEusyi30DmHplDzGZ9yKgLIoC/dN
         VRR5sZMY+bewLN09DzyoltWt1z/sVBBbWk786QLQMz7nJlkzzmGSNsHgPSMWezZdp5EQ
         69y9ZINZUZW5olveS0MPr9DBYsxRS0MnXM+/bLuSo/hqV9QpFH40plPnAgWBNtWks1UD
         lRl/Lsbc4IqPRxCNF1dyWZoMp+R1qWl+EvIipVOVIrRFu28R7f8Qn1xzBulrUyyAunow
         gatSt/H90kT+ENZRwJmMjzJg2raOwikyCjiXI8XQuM5f+xreZDZBQZdnzbISmaxf90u6
         vbAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b=GWhicdJz;
       spf=pass (google.com: domain of prvs=060300392=graf@amazon.com designates 72.21.196.25 as permitted sender) smtp.mailfrom="prvs=060300392=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
Received: from smtp-fw-2101.amazon.com (smtp-fw-2101.amazon.com. [72.21.196.25])
        by mx.google.com with ESMTPS id c80si1148428qke.221.2019.06.13.00.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 00:20:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=060300392=graf@amazon.com designates 72.21.196.25 as permitted sender) client-ip=72.21.196.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b=GWhicdJz;
       spf=pass (google.com: domain of prvs=060300392=graf@amazon.com designates 72.21.196.25 as permitted sender) smtp.mailfrom="prvs=060300392=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1560410448; x=1591946448;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=dhmXrepDAZcjXkpQs5VfxOBzitc3aINuYRH8cXmOgbc=;
  b=GWhicdJzBpWeJdgTa7sgEYhPFV3t6Oyh9XsErtlfW76CtRRC5iZR+nBE
   qhghegzUiVbUo1ul+bNUu7mxZWUA9NvCdURG0rJdnAUqSNT07VRcDGlhI
   2herR7rcSnOTimoyXZNMNu7IB8pvKN/Cn7NeCeBwx+sNGjrYu48KEg2fq
   c=;
X-IronPort-AV: E=Sophos;i="5.62,368,1554768000"; 
   d="scan'208";a="737272759"
Received: from iad6-co-svc-p1-lb1-vlan2.amazon.com (HELO email-inbound-relay-1a-7d76a15f.us-east-1.amazon.com) ([10.124.125.2])
  by smtp-border-fw-out-2101.iad2.amazon.com with ESMTP; 13 Jun 2019 07:20:46 +0000
Received: from EX13MTAUWC001.ant.amazon.com (iad55-ws-svc-p15-lb9-vlan2.iad.amazon.com [10.40.159.162])
	by email-inbound-relay-1a-7d76a15f.us-east-1.amazon.com (Postfix) with ESMTPS id 254ACA26DA;
	Thu, 13 Jun 2019 07:20:44 +0000 (UTC)
Received: from EX13D20UWC001.ant.amazon.com (10.43.162.244) by
 EX13MTAUWC001.ant.amazon.com (10.43.162.135) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Thu, 13 Jun 2019 07:20:43 +0000
Received: from 38f9d3867b82.ant.amazon.com (10.43.160.69) by
 EX13D20UWC001.ant.amazon.com (10.43.162.244) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Thu, 13 Jun 2019 07:20:41 +0000
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Sean Christopherson <sean.j.christopherson@intel.com>, Marius Hillenbrand
	<mhillenb@amazon.de>
CC: <kvm@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-hardening@lists.openwall.com>, <linux-mm@kvack.org>, Alexander Graf
	<graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <20190612182550.GI20308@linux.intel.com>
From: Alexander Graf <graf@amazon.com>
Message-ID: <7162182f-74e5-9be7-371d-48ee483206c2@amazon.com>
Date: Thu, 13 Jun 2019 09:20:40 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190612182550.GI20308@linux.intel.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Originating-IP: [10.43.160.69]
X-ClientProxiedBy: EX13D22UWC001.ant.amazon.com (10.43.162.192) To
 EX13D20UWC001.ant.amazon.com (10.43.162.244)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 12.06.19 20:25, Sean Christopherson wrote:
> On Wed, Jun 12, 2019 at 07:08:24PM +0200, Marius Hillenbrand wrote:
>> The Linux kernel has a global address space that is the same for any
>> kernel code. This address space becomes a liability in a world with
>> processor information leak vulnerabilities, such as L1TF. With the right
>> cache load gadget, an attacker-controlled hyperthread pair can leak
>> arbitrary data via L1TF. Disabling hyperthreading is one recommended
>> mitigation, but it comes with a large performance hit for a wide range
>> of workloads.
>>
>> An alternative mitigation is to not make certain data in the kernel
>> globally visible, but only when the kernel executes in the context of
>> the process where this data belongs to.
>>
>> This patch series proposes to introduce a region for what we call
>> process-local memory into the kernel's virtual address space. Page
>> tables and mappings in that region will be exclusive to one address
>> space, instead of implicitly shared between all kernel address spaces.
>> Any data placed in that region will be out of reach of cache load
>> gadgets that execute in different address spaces. To implement
>> process-local memory, we introduce a new interface kmalloc_proclocal() /
>> kfree_proclocal() that allocates and maps pages exclusively into the
>> current kernel address space. As a first use case, we move architectural
>> state of guest CPUs in KVM out of reach of other kernel address spaces.
> Can you briefly describe what types of attacks this is intended to
> mitigate?  E.g. guest-guest, userspace-guest, etc...  I don't want to
> make comments based on my potentially bad assumptions.


(quickly jumping in for Marius, he's offline today)

The main purpose of this is to protect from leakage of data from one 
guest into another guest using speculation gadgets on the host.

The same mechanism can be used to prevent leakage of secrets from one 
host process into another host process though, as host processes 
potentially have access to gadgets via the syscall interface.


Alex

