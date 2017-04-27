Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC496B02EE
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:42:01 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p18so3109498wrb.22
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 06:42:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j23si2639177wre.45.2017.04.27.06.41.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 06:41:59 -0700 (PDT)
Date: Thu, 27 Apr 2017 15:41:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] Remove hardcoding of ___GFP_xxx bitmasks
Message-ID: <20170427134158.GI4706@dhcp22.suse.cz>
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
 <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 26-04-17 18:29:08, Igor Stoppa wrote:
[...]
> If you prefer to have this patch only as part of the larger patchset,
> I'm also fine with it.

I agree that the situation is not ideal. If a larger set of changes
would benefit from this change then it would clearly add arguments...

> Also, if you could reply to [1], that would be greatly appreciated.

I will try to get to it but from a quick glance, yet-another-zone will
hit a lot of opposition...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
