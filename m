Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5B806B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 02:21:22 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so55170768wmd.6
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:21:22 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k15si10914195wmi.37.2016.11.30.23.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 23:21:21 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id m203so32662449wma.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:21:21 -0800 (PST)
Date: Thu, 1 Dec 2016 08:21:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
Message-ID: <20161201072119.GD18272@dhcp22.suse.cz>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
 <20161201071507.GC18272@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201071507.GC18272@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Robin H. Johnson" <robbat2@gentoo.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Joonsoo Kim <js1304@gmail.com>

Forgot to CC Joonsoo. The email thread starts more or less here
http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz

On Thu 01-12-16 08:15:07, Michal Hocko wrote:
> On Wed 30-11-16 20:19:03, Robin H. Johnson wrote:
> [...]
> > alloc_contig_range: [83f2a3, 83f2a4) PFNs busy
> 
> Huh, do I get it right that the request was for a _single_ page? Why do
> we need CMA for that?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
