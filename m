Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id AFCC86B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 12:13:26 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id n4so23889071qaq.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:13:26 -0800 (PST)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com. [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id i38si1058612qkh.83.2015.03.02.09.13.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 09:13:26 -0800 (PST)
Received: by mail-qa0-f48.google.com with SMTP id dc16so23817427qab.7
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:13:25 -0800 (PST)
Date: Mon, 2 Mar 2015 12:13:23 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: disable hierarchy support if bound to the
 legacy cgroup hierarchy
Message-ID: <20150302171323.GM17694@htj.duckdns.org>
References: <131af5f5ee0eec55d0f94a785db4be04baf01f51.1424356325.git.vdavydov@parallels.com>
 <421fb6bbff04eb70b8ad82b51efd373f0b4d170f.1424356325.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <421fb6bbff04eb70b8ad82b51efd373f0b4d170f.1424356325.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Feb 19, 2015 at 05:34:47PM +0300, Vladimir Davydov wrote:
> If the memory cgroup controller is initially mounted in the scope of the
> default cgroup hierarchy and then remounted to a legacy hierarchy, it
> will still have hierarchy support enabled, which is incorrect. We should
> disable hierarchy support if bound to the legacy cgroup hierarchy.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Johannes, Michal, can you guys pick this up?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
