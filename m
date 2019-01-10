Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92040C43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 18:26:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E01A20675
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 18:26:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E01A20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BB848E0006; Thu, 10 Jan 2019 13:26:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06C2B8E0001; Thu, 10 Jan 2019 13:26:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E75168E0006; Thu, 10 Jan 2019 13:26:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBAFC8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:26:37 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id h85so5580006oib.9
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:26:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=iVteJyD1IXWZpRvWbw2yeHtRy4soWUpnCawmJq4icNg=;
        b=iqAcyV5RW9MAXKyjQMOJspnXLgN530UEpUZXxOPp21U3ASl2ly0VCAti0dK81XcFWi
         gJta3OhyUngU4PimMqRsbJ6hOdEHMIhyPkDwmB7jVF7hzd9o1KJbXDmarNyoT9SZtJHV
         GtUt5QnDxfUAy/xKClLJqvFriGNNnKXYqYzcB1UihsyLJxrctosfSIJpVWN3BN1KCaVm
         ROYQFBi49hHJsbWzeY9bTFO3qtFHPv/X0qzORwxfgsex3cFN/UM33HivCGXiRlVSjTZC
         pGb+DKlkMzg1Bx9yyGwlCWylr4CgQkWMDCzl8/aMxIi1hGjbTUMkHaLNvqj5wC4zhKLI
         QqhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AJcUukfs2zsol9ETpX/0zx2jHea55ppOS7qwZITB8vJ+Yn2UGi1cqoo7
	u20Izm+Bl9O6vjtLhH14J6HFiWfx9NlNML2vh2fIGK/oUvaUrD/hollbyJa+Z1NPCYi8nd8Fe4Z
	MO19fEZU1e+0y9Ysc4CCjh2cv0zKrYBzFZo4AroSxf4JUAb/Pe3Kl6Oicy2ihZU/TYQ==
X-Received: by 2002:aca:5344:: with SMTP id h65mr7401641oib.13.1547144797483;
        Thu, 10 Jan 2019 10:26:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7oB1PJdMjkdhGRR1AY0iORfbXNeNpCwYQcyIA8bNJm0JdMOoY9prg53GTUlfwuMzsow6QL
X-Received: by 2002:aca:5344:: with SMTP id h65mr7401618oib.13.1547144796669;
        Thu, 10 Jan 2019 10:26:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547144796; cv=none;
        d=google.com; s=arc-20160816;
        b=WrP9KD4mLcBGix+Xqcms387hv5sUyxAUuUoQSCdVstnxPH24sAuIuWwCX1/NJY5msx
         fLQvUEqdUp0K+j1sUT5Ww+O13a6Rd/bViBC6k67KUGR2lbfT5VD0UVJ56jG6ZkWAvX/t
         LB4KYbUIBUh6lHFf7mtNxA/5Hy6mEUNHu/OP2IU8RIfQZ/LYuJWb0s9T5QzDzwb2Fs9u
         s+XC6AJntaH0wVJDPFBM5BtHLhUnm6+A12GnMjKet6AEbIjqk5JLbH2GvbLLnQv/tuih
         lT32/Bna7P+l7JBBVT/qnBEkCEdBSxMoC5YUZfKHYaS/XHM5i9YsbAx/oHVdbxW0SSZ2
         GVmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=iVteJyD1IXWZpRvWbw2yeHtRy4soWUpnCawmJq4icNg=;
        b=jN6rgM1LQlnAn4I4MvJ2b4tHiTKn4DxrO3h0VUusKJ4rs74eWyEujghVPuRk+4jKlK
         SyVpnP8D1xXxEwQ03LY7/tyyJTWOohnKWwjHcwqkVwyGvzD6HcJ88UnOaA9RekK8ZF/O
         pB8FIjeDcHmRL4GNvNEke2vtjeh6vVcKeFydichlt6k6mBgNpxS6mVd0uMTsnoSxhKOT
         22BNRl0JB/8YQx+X16v2Z0pw1Z3iArFs0y/KHPIH8mcNf9t8TcxukGrFZ5whP8mhFe7r
         QTx9Ocu4GBn+22/rrGRZGEgsx85/+dlHN8P/eUVxZ/6wKBbgEo4baY0Srf+SC70dF+V8
         ZX7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id v19si29117112oif.242.2019.01.10.10.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 10:26:36 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 8B6B6B2D781288A6371F;
	Fri, 11 Jan 2019 02:26:30 +0800 (CST)
Received: from localhost (10.202.226.46) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Fri, 11 Jan 2019
 02:26:25 +0800
Date: Thu, 10 Jan 2019 18:26:10 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Linux Memory Management List
	<linux-mm@kvack.org>, <kvm@vger.kernel.org>, LKML
	<linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan
	<yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying
	<ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie
	<eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi
	<yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "Mel
 Gorman" <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>,
	<linux-accelerators@lists.ozlabs.org>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110182610.00004250@huawei.com>
In-Reply-To: <20190108145256.GX31793@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
	<20181227203158.GO16738@dhcp22.suse.cz>
	<20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
	<20181228084105.GQ16738@dhcp22.suse.cz>
	<20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
	<20181228121515.GS16738@dhcp22.suse.cz>
	<20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
	<20181228195224.GY16738@dhcp22.suse.cz>
	<20190102122110.00000206@huawei.com>
	<20190108145256.GX31793@dhcp22.suse.cz>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.46]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110182610.yYQae1aWsghEcPv6J8O4SIBAaPFwneqXmL1b3DtDLtM@z>

On Tue, 8 Jan 2019 15:52:56 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 02-01-19 12:21:10, Jonathan Cameron wrote:
> [...]
> > So ideally I'd love this set to head in a direction that helps me tick off
> > at least some of the above usecases and hopefully have some visibility on
> > how to address the others moving forwards,  
> 
> Is it sufficient to have such a memory marked as movable (aka only have
> ZONE_MOVABLE)? That should rule out most of the kernel allocations and
> it fits the "balance by migration" concept.

Yes, to some degree. That's exactly what we are doing, though a things currently
stand I think you have to turn it on via a kernel command line and mark it
hotpluggable in ACPI. Given it my or may not actually be hotpluggable
that's less than elegant.

Let's randomly decide not to explore that one further for a few more weeks.
la la la la

If we have general balancing by migration then things are definitely
heading in a useful direction as long as 'hot' takes into account the
main user not being a CPU.  You are right that migration dealing with
the movable kernel allocations is a nice side effect though which I
hadn't thought about.  Long run we might end up with everything where
it should be after some level of burn in period. A generic version of
this proposal is looking nicer and nicer!

Thanks,

Jonathan





