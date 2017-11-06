Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97F1A6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 08:05:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l24so12725923pgu.17
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 05:05:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si10151722ple.534.2017.11.06.05.05.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 05:05:10 -0800 (PST)
Date: Mon, 6 Nov 2017 14:05:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Message-ID: <20171106130507.bm75uclqqoniqwdv@dhcp22.suse.cz>
References: <CACAwPwY0owut+314c5sy7jNViZqfrKy3sSf1hjLTocXefrz3xA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACAwPwY0owut+314c5sy7jNViZqfrKy3sSf1hjLTocXefrz3xA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat 04-11-17 11:55:14, Maxim Levitsky wrote:
> Hi!
> 
> My system has 64G of ram and I want to create 32 1G huge pages to use
> in KVM virtualization,
> on demand, only when VM is running.
> 
> So I booted the kernel with
> 'hugepagesz=1G hugepages=0 default_hugepagesz=1G movablecore=40G'

Why do you think movablecore will help you? Giga pages are not
migrateable and as such they do not end up on movable zones.

I have recently changed the code to reflect that reality because
allowing giga pages to consume movable zone simply breaks memory
hotplug.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
