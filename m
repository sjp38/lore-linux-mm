Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB666B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 02:15:10 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xr1so36888994wjb.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:15:10 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id r188si10918579wme.5.2016.11.30.23.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 23:15:09 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id g23so32762781wme.1
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:15:09 -0800 (PST)
Date: Thu, 1 Dec 2016 08:15:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
Message-ID: <20161201071507.GC18272@dhcp22.suse.cz>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Robin H. Johnson" <robbat2@gentoo.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org

On Wed 30-11-16 20:19:03, Robin H. Johnson wrote:
[...]
> alloc_contig_range: [83f2a3, 83f2a4) PFNs busy

Huh, do I get it right that the request was for a _single_ page? Why do
we need CMA for that?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
