Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA866B0260
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 06:28:49 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so84937976wjb.7
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 03:28:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j6si45894871wmd.67.2016.12.27.03.28.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Dec 2016 03:28:47 -0800 (PST)
Date: Tue, 27 Dec 2016 12:28:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Bug 4.9 and memorymanagement
Message-ID: <20161227112844.GG1308@dhcp22.suse.cz>
References: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
 <20161226110053.GA16042@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161226110053.GA16042@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Klaus Ethgen <Klaus+lkml@ethgen.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 26-12-16 12:00:53, Michal Hocko wrote:
> [CCing linux-mm]
> 
> On Sun 25-12-16 21:52:52, Klaus Ethgen wrote:
> > Hello,
> > 
> > The last days I compiled version 4.9 for my i386 laptop. (Lenovo x61s)
> 
> Do you have memory cgroups enabled in runtime (aka does the same happen
> with cgroup_disable=memory)?

If this turns out to be memory cgroup related then the patch from
http://lkml.kernel.org/r/20161226124839.GB20715@dhcp22.suse.cz might
help.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
