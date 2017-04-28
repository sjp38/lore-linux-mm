Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC706B02F2
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 04:15:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k14so10747405pga.5
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 01:15:21 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id d2si5589501pgf.380.2017.04.28.01.15.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Apr 2017 01:15:20 -0700 (PDT)
Subject: Re: [PATCH 1/1] Remove hardcoding of ___GFP_xxx bitmasks
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
 <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
 <20170427134158.GI4706@dhcp22.suse.cz>
 <f741d053-4303-5441-21bc-ec86bca1164c@huawei.com>
 <20170428074028.GF8143@dhcp22.suse.cz>
 <4b077316-b381-08d7-7797-1eaf65d01a02@huawei.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <431cb2b7-0d2e-3c70-2e8f-d1cc651ebc0d@huawei.com>
Date: Fri, 28 Apr 2017 11:13:40 +0300
MIME-Version: 1.0
In-Reply-To: <4b077316-b381-08d7-7797-1eaf65d01a02@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 28/04/17 10:43, Igor Stoppa wrote:

[...]

> I'm writing an alternative different proposal, let's call it last attempt.
> 
> Should be ready in a few minutes.

Here: http://marc.info/?l=linux-mm&m=149336675129967&w=2

--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
