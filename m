Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23B69C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 17:43:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB86F20881
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 17:43:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB86F20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 750708E0002; Mon, 28 Jan 2019 12:43:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7001E8E0001; Mon, 28 Jan 2019 12:43:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EF818E0002; Mon, 28 Jan 2019 12:43:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3988E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:43:00 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id o11so4719272vke.5
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:43:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=7sqKBm6b2VKkB7E7B7WUF3lomqQBXd3MBh/YsvuyDc0=;
        b=efMj5lrqL8jhEgFnbrCjzc+kHd47X0kd0XRUMgIXATUYvNhJF9T3U4WwCVjg4k63cb
         BF1uIufAZFRi8Oo0RGr3afLU0M4Pai+xQ9B8vnmDBmNKh6p1bAeAwQL3TCdCii/+yWi6
         hSvjuV1ZvQebo0PU9T1H3KzWmiV7VeVWFqbBsLzo+xJRKXf6o6TBAGHzlMy8HGXheikU
         YHVPEl3yzUSqlTRvJaTe8mjNxor/SqH0uxA1VXk3LgclSYggwDxd9HyvMxM4TgNWlswS
         BQdXML9eXkszcCc8/8atwTXT59kNwlIFR76TGcfPn3dikOSl8UojOZ8hKd1IkZWWAQSH
         zSYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AJcUukf4S8TLWzVnr4sd8b1N7Kw3LW9t9I+S0FQLSh8WWyHPFJhfGFV2
	k8Akr8W2CQ5G5Hctrpw8624bJ+Dij9VuH0Xr0au31ZCgrAtsav0tdhOymGfoNvIdln3JfyW4A/C
	oEvzF8cgWNvrZtjEtsAw63orGaTW97m1WLtDoi8R0lo30PPvIBOlegU/qmFroZRrzhg==
X-Received: by 2002:a67:f696:: with SMTP id n22mr10000833vso.175.1548697379852;
        Mon, 28 Jan 2019 09:42:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Sp2244WsyJPcciWnkx/1HLb9xpBDNlc5CbIP+kPwVdHAxcs21P/ASVQFPY/svzJdnl/0V
X-Received: by 2002:a67:f696:: with SMTP id n22mr10000808vso.175.1548697378981;
        Mon, 28 Jan 2019 09:42:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548697378; cv=none;
        d=google.com; s=arc-20160816;
        b=vO1h1nM/KzScqTJiX3fx+FOXz8zIi/zrJZN+RI2JvjU/WFqb9iJvIElqNg1KlyvOPP
         iB0tuwj2kj6ZdYlv08coEgBrUzg/qEAv1Ki0nXQtYpw/a0wcOWquw0BqUL6kBntOACVm
         Yqq6w/Y6LC0bkiu+yKLsspTbRQryR72QjQf0qyf2Vb7D+1wkVVhJR0kbqwJUEYAGjE8e
         4gYy2jOO+fEmPbrcyaCAe4TDpKp3qfjURfdvoBXBKZ7H2qd97WEVuoflfeuCbbvoHaKw
         oOfXk+pg/4ZzEG1Gp6HwNgMz+Z9i/XlHDFjS3OoRTgzU9D+egl5OByQAGqG8sbyzIzCe
         jWvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=7sqKBm6b2VKkB7E7B7WUF3lomqQBXd3MBh/YsvuyDc0=;
        b=PNuZd3UzRxJDMzz1el2/Ih5CJuJTeS62vevMiUMyHQ/abe5HnoFIrdLolt0poR+RIr
         1D5XflyIlVhK+7a1Fak3U4aYllns1hlKqKI9IfV55U2QYE4EyCuPRPZkAS1tiw9aqoy6
         mQMAGFi0AKxcT46b2+xVD4WmFusLPCezVNUGjwO8jHAszFQE2U/rRsxIR7zFV1bep+Vb
         lLACb2lTCc70T1x+JJO7tAEAk115TZu8a2xz/Lxw+6gKeGjM2EoiI4juNm4PoRFOZrHN
         +iiDVYQgw7PGxZJjs2Fk1NNhBQqpEh7chdVT5/R2UOnBridR4MzBwaq5JxJc8l8Ly9h8
         Vpgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id t62si263411uat.137.2019.01.28.09.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 09:42:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 3D9677F03AFBD8EF99CE;
	Tue, 29 Jan 2019 01:42:55 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Tue, 29 Jan 2019
 01:42:52 +0800
Date: Mon, 28 Jan 2019 17:42:39 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Andrea Arcangeli <aarcange@redhat.com>, Huang Ying <ying.huang@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>, <kvm@vger.kernel.org>, Dave Hansen
	<dave.hansen@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Fan Du
	<fan.du@intel.com>, Dong Eddie <eddie.dong@intel.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-accelerators@lists.ozlabs.org>,
	"Linux Memory Management List" <linux-mm@kvack.org>, Peng Dong
	<dongx.peng@intel.com>, Yao Yuan <yuan.yao@intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, "Dan
 Williams" <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190128174239.0000636b@huawei.com>
In-Reply-To: <20190102122110.00000206@huawei.com>
References: <20181226131446.330864849@intel.com>
	<20181227203158.GO16738@dhcp22.suse.cz>
	<20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
	<20181228084105.GQ16738@dhcp22.suse.cz>
	<20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
	<20181228121515.GS16738@dhcp22.suse.cz>
	<20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
	<20181228195224.GY16738@dhcp22.suse.cz>
	<20190102122110.00000206@huawei.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128174239.4T0MpNu8kXj0OMm8T82uC19D0tONYtJpBgwqzE9hLDg@z>

On Wed, 2 Jan 2019 12:21:10 +0000
Jonathan Cameron <jonathan.cameron@huawei.com> wrote:

> On Fri, 28 Dec 2018 20:52:24 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > [Ccing Mel and Andrea]
> > 

Hi,

I just wanted to highlight this section as I didn't feel we really addressed this
in the earlier conversation.

> * Hot pages may not be hot just because the host is using them a lot.  It would be
>   very useful to have a means of adding information available from accelerators
>   beyond simple accessed bits (dreaming ;)  One problem here is translation
>   caches (ATCs) as they won't normally result in any updates to the page accessed
>   bits.  The arm SMMU v3 spec for example makes it clear (though it's kind of
>   obvious) that the ATS request is the only opportunity to update the accessed
>   bit.  The nasty option here would be to periodically flush the ATC to force
>   the access bit updates via repeats of the ATS request (ouch).
>   That option only works if the iommu supports updating the accessed flag
>   (optional on SMMU v3 for example).
> 

If we ignore the IOMMU hardware update issue which will simply need to be addressed
by future hardware if these techniques become common, how do we address the
Address Translation Cache issue without potentially causing big performance
problems by flushing the cache just to force an accessed bit update?

These devices are frequently used with PRI and Shared Virtual Addressing
and can be accessing most of your memory without you having any visibility
of it in the page tables (as they aren't walked if your ATC is well matched
in size to your usecase.

Classic example would be accelerated DB walkers like the the CCIX demo
Xilinx has shown at a few conferences.   The whole point of those is that
most of the time only your large set of database walkers is using your
memory and they have translations cached for for a good part of what
they are accessing.  Flushing that cache could hurt a lot.
Pinning pages hurts for all the normal flexibility reasons.

Last thing we want is to be migrating these pages that can be very hot but
in an invisible fashion.

Thanks,

Jonathan
 


