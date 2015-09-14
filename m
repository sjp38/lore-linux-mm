Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 504996B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:51:33 -0400 (EDT)
Received: by ykdt18 with SMTP id t18so136663267ykd.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:51:33 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id n127si6658283ywf.17.2015.09.14.08.51.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:51:32 -0700 (PDT)
Received: by ykft14 with SMTP id t14so5035335ykf.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:51:32 -0700 (PDT)
Date: Mon, 14 Sep 2015 11:51:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] memcg: ratify and consolidate over-charge handling
Message-ID: <20150914155129.GB20047@mtj.duckdns.org>
References: <20150913201416.GC25369@htj.duckdns.org>
 <20150913201442.GD25369@htj.duckdns.org>
 <20150914124420.GE30743@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914124420.GE30743@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Vladmir.

On Mon, Sep 14, 2015 at 03:44:20PM +0300, Vladimir Davydov wrote:
> Hmm, cancel_charge(root_mem_cgroup) is a no-op. Looks like this is a
> leftover from the times when we did charge root_mem_cgroup.

Yeap, it's inconsistent but not broken.  Will not that in the
description.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
