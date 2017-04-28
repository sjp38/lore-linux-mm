Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA5B6B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 03:44:12 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 75so9586683uak.19
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 00:44:12 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id r85si2905714vke.40.2017.04.28.00.44.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Apr 2017 00:44:11 -0700 (PDT)
Subject: Re: [PATCH 1/1] Remove hardcoding of ___GFP_xxx bitmasks
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
 <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
 <20170427134158.GI4706@dhcp22.suse.cz>
 <f741d053-4303-5441-21bc-ec86bca1164c@huawei.com>
 <20170428074028.GF8143@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <4b077316-b381-08d7-7797-1eaf65d01a02@huawei.com>
Date: Fri, 28 Apr 2017 10:43:09 +0300
MIME-Version: 1.0
In-Reply-To: <20170428074028.GF8143@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 28/04/17 10:40, Michal Hocko wrote:

> Do not add a new zone, really. What you seem to be looking for is an
> allocator on top of the page/memblock allocator which does write
> protection on top. I understand that you would like to avoid object
> management duplication but I am not really sure how much you can re-use
> what slab allocators do already, anyway. I will respond to the original
> thread to not mix things together.

I'm writing an alternative different proposal, let's call it last attempt.

Should be ready in a few minutes.

thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
