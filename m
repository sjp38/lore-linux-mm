Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2F99E6B003A
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:20:37 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so1827051eek.16
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:20:36 -0700 (PDT)
Received: from mail-ee0-x235.google.com (mail-ee0-x235.google.com [2a00:1450:4013:c00::235])
        by mx.google.com with ESMTPS id z2si41344602eeo.214.2014.04.18.11.20.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 11:20:35 -0700 (PDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so1820376eek.26
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:20:35 -0700 (PDT)
Date: Fri, 18 Apr 2014 20:20:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg with kmem limit doesn't recover after disk i/o causes
 limit to be hit
Message-ID: <20140418182033.GA22235@dhcp22.suse.cz>
References: <20140416154650.GA3034@alpha.arachsys.com>
 <20140418155939.GE4523@dhcp22.suse.cz>
 <5351679F.5040908@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5351679F.5040908@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Richard Davies <richard@arachsys.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri 18-04-14 21:57:51, Vladimir Davydov wrote:
> In short, kmem limiting for memory cgroups is currently broken. Do not
> use it. We are working on making it usable though.

Maybe we should make this explicit in both
Documentation/cgroups/memory.txt and config MEMCG_KMEM help text.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
