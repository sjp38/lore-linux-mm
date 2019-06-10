Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F15F2C31E43
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:46:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C300820820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:46:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C300820820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54CEB6B026C; Mon, 10 Jun 2019 12:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FEEF6B026D; Mon, 10 Jun 2019 12:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EC916B026E; Mon, 10 Jun 2019 12:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 052496B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:46:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so16140332edc.17
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:46:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9H25zsY7K3uH7vHtRU+jcD97JXPrTVo0+KNQXui+OCA=;
        b=Bp8MwCXlbjsagsSmSnDC1yF/RJucMuXnJt6YC3flNzHWvGDTdT0QQLjpui3kV5WumR
         liAZUhq+fp3yi5Fg8ungkEQyK8ypIBk5L1fpSHkE11eXa+2j2opxi8bXxdMqUdVIcQ3x
         Yqd+ehgvGZ/XeAf05HQcg2Ip0CEIYayOsbCOeeLQ4QLXyTnlBsPHWGE8PbvHlv+55fvO
         TNkDfcqxJGJY+hoOTxFWbplb6PB83pYSxTWofdYOz0GAa8IjV89md7Zg13ziN84tDbmx
         TB1XCbI76XQFvpipaOPvG3PwLT6VI62TA8oG3U4CgEZmkjFWQjPM6vU8ThqEUYFlN5Ga
         iDJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWhGhEz9zAbslbEMFEYqUIeslqVECSvRPnymiIbssTonT9oHmsy
	HNn0K6QZ3OCLUcjH6S3zQROkkJ7R2XOkgn9CetltO0bSTdtc+RMPzP/0n4315wmMIbUbZTbXVud
	YJ24CpF9sb3HEsbC2vIuEtQmYWD4cvNNVXE+uKvVyWiAGzCBUoQAsKkmpCb0xid/H2w==
X-Received: by 2002:a17:906:858f:: with SMTP id v15mr15592045ejx.252.1560185194579;
        Mon, 10 Jun 2019 09:46:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6Sg+ullt6V8KulPryVth3EL1OkI50nHpgVxZkRg6S6DVqR7XxssbhnMxXdmxSKD8Ifso5
X-Received: by 2002:a17:906:858f:: with SMTP id v15mr15591981ejx.252.1560185193560;
        Mon, 10 Jun 2019 09:46:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560185193; cv=none;
        d=google.com; s=arc-20160816;
        b=wZwIgbCMVUMbdA61i2SOzDIbC6IToXWkPyhorSl++nwns8VUvMFvltU+50Zse4trha
         6uGXKn/WQN2DBskb+7mMhimBZ6ofxvNFBMnu0WqhO3q+tZUi4ZZqHPqxyiLoaVcg93aT
         7++McRouA7udZaAoVCkHSillzwc8Imh66ADw7edfEyiIwwCCnhqYoqts3XLQ5z9iQIrN
         2LAzkHmqkNuia7FojlwcpzYk7BM/JgHGuNb8QjNQL1fBUg1pLr9xghWgLgu55K8W7wK9
         CQEjVfFX8iXUaBmdloMPBFyKt7+nbT07MILbGh2f7joKzg+MHwkj2j3Fg35GChFoIsXQ
         xb0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9H25zsY7K3uH7vHtRU+jcD97JXPrTVo0+KNQXui+OCA=;
        b=v/JUQpT3Ijh3I2d72OcXup868rbE9Fg6Cmwlj6wArMbRKrscFFAdmwY6VT7zt5l3AW
         pIvlpK7JVLm6Noao8fEU/kpGCjCyqv+bJwO3f5rkTQlk1zb0FhCYCk701W15BC4jpRVz
         IhofrB5uV4Rp6+WhrSDbw7CTo1gOh8E7JcqecPsayxibTftf93qdFIQOWM8zZ04unKzj
         EBE6nZED9XqV7sBFj71OTUWbyDVV/bQ3UYkG10a2u4b0VYdHMf92Ci04RItB8dkMp94A
         i7qb3cXBnMxaRjQagxdi1LwgAlKw8iC9p7PizY/lniIVY3+8kVwwwAWk0Y0o3tclG8gK
         ZQoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si1647529eda.160.2019.06.10.09.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 09:46:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6FFB8AD0C;
	Mon, 10 Jun 2019 16:46:32 +0000 (UTC)
Date: Mon, 10 Jun 2019 18:46:27 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: Re: [PATCH v3 01/11] mm/memory_hotplug: Simplify and fix
 check_hotplug_memory_range()
Message-ID: <20190610164622.GA5643@linux>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-2-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:42PM +0200, David Hildenbrand wrote:
> By converting start and size to page granularity, we actually ignore
> unaligned parts within a page instead of properly bailing out with an
> error.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

