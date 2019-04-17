Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FA7CC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 22:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29FA52186A
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 22:03:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29FA52186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA1F16B0005; Wed, 17 Apr 2019 18:03:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A515B6B0006; Wed, 17 Apr 2019 18:03:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9686F6B0007; Wed, 17 Apr 2019 18:03:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6042E6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 18:03:34 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f7so47307pfd.7
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:03:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YPnM+aIdI0nZFi+ijgIyla4FOMpm7gn3vPN8WszuCLs=;
        b=Wbkz/ribNTBZpARAKedisMCb38CwopQl+4GVFhzK8f6/HTLzZnbFI8TyMpQW23kR+c
         GeLbwAxEKMwxfR1URRQ/qugaEcPQw2uVOJPmESu6r6WvMZXK3a4yirzS13noGBiCpTE+
         8LnNq7r5COaafGjL23GOItvITpmqiqOwT86Jq6rDLhhsJyyt7vTAvUWpu7TmrRZEo1fV
         OD4X6YUGasNrzS5KsgzYwhaYmvdrqVxWdSuDi/6nV029zBDypBl82K47L8hK+zQbLu7M
         50VfAZ4thVUe2xzg5nab86BUsYxllCa8mPdoAT01N2Km9aLUTVaw6JgUVEXuLS03+TrP
         mm9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXgU4N2SXNEqtOarnT0id/VhvvUeq9N1u0zXVjV8bsRhup8XgvW
	QzHG0ERCqHgcPJg4NpB6OC9CzdG42NNmPv4+oPflc9rZ0Td+6nhzYzZAyjoP5D564uylCN8BTeW
	foLSuGEBjqHFa1mIHS1Fh3y7t/1/gVzO4FG5l5DlZxNxjOPpcZF8sjBeDipNsSvZ4sQ==
X-Received: by 2002:a17:902:7601:: with SMTP id k1mr54491963pll.35.1555538614097;
        Wed, 17 Apr 2019 15:03:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnri5yD7FYVhxuH3C0wVZ322w5dDzg/Jw7MHDxmIeO4i7PCNGQSgDiy/cJn7nGc491BI30
X-Received: by 2002:a17:902:7601:: with SMTP id k1mr54491903pll.35.1555538613518;
        Wed, 17 Apr 2019 15:03:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538613; cv=none;
        d=google.com; s=arc-20160816;
        b=zzVKeJXDcOLVk92YyWZ2IzPzAQ0mEAwO7DqedwmBcSEEvLnrRDR15g7kg/ZYJgJOhU
         IxiU4POzC7oYcp32xHUCp0Ro449P9YVzX3y4/WQq9lG4nZALISOxlsLBz+02Lld6cEz2
         4BfHG993fnSVQ/OQJOG2GJIHXSb9vbVMySj+TdmB+AP7cjfIfw6HD6ZLiWv8G/01WTw0
         NmjY/SKczkIUNCyRECIpuWyOvOVFDD6Ac7k2MshvyksKWno73aNFOBHz9MbULRXBO3qu
         cj3PyoATycCaIODU1HKMN40GEOo+i5tQ2CamVDI78D76tC6r8PEaZLbtvQoadsagS+Cd
         VCCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=YPnM+aIdI0nZFi+ijgIyla4FOMpm7gn3vPN8WszuCLs=;
        b=AxadSRpnw3EwEsmcUEyhJmYNkEPSM1dLDEesK/sZ7mqpv9vQSqrcxuLy2h7E7vkdIL
         pgysqLvy1QD30s8ktS3ZJi/eA3nOTj8l/Q0KVWTn+sTr8tiizp6/kpCzFZHEhVzpd+Ng
         sf8bPdtVwzxvLupgujpUtp73SOveKbtyCsaX+mSvsoxDs0LAOPUruRg8yocd3SQQLLdD
         V5uVxouTCLXMZxpu9wRU5qLnIAvft8OF1773vyEw321ApmgUhgZ6ylUxgdA02efRvk2k
         Tl3f0a4LLJ+SOEVkLXvknVoPfJaTQyke9cLvcIucb5DuTv4VQplJejxH/HuedpCvWKFZ
         C8ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i14si39366pgb.0.2019.04.17.15.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 15:03:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id E04B4B3E;
	Wed, 17 Apr 2019 22:03:32 +0000 (UTC)
Date: Wed, 17 Apr 2019 15:03:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: David Hildenbrand <david@redhat.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Toshi Kani
 <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, Michal Hocko
 <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 stable@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
Message-Id: <20190417150331.90219ca42a1c0db8632d0fd5@linux-foundation.org>
In-Reply-To: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019 11:38:55 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> The memory hotplug section is an arbitrary / convenient unit for memory
> hotplug. 'Section-size' units have bled into the user interface
> ('memblock' sysfs) and can not be changed without breaking existing
> userspace. The section-size constraint, while mostly benign for typical
> memory hotplug, has and continues to wreak havoc with 'device-memory'
> use cases, persistent memory (pmem) in particular. Recall that pmem uses
> devm_memremap_pages(), and subsequently arch_add_memory(), to allocate a
> 'struct page' memmap for pmem. However, it does not use the 'bottom
> half' of memory hotplug, i.e. never marks pmem pages online and never
> exposes the userspace memblock interface for pmem. This leaves an
> opening to redress the section-size constraint.

v6 and we're not showing any review activity.  Who would be suitable
people to help out here?

