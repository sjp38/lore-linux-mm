Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5E28E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 04:52:36 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so101334edq.4
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 01:52:36 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v8si2750015edr.310.2019.01.07.01.52.35
        for <linux-mm@kvack.org>;
        Mon, 07 Jan 2019 01:52:35 -0800 (PST)
Date: Mon, 7 Jan 2019 09:52:30 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: kmemleak: Cannot allocate a kmemleak_object structure - Kernel
 4.19.13
Message-ID: <20190107095229.uvfuxpglreibxlo4@mbp>
References: <CALaQ_hpCKoLxp-0cgxw9TqPGBSzY7RhrnFZ0jGAQ11HbOZkZ3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALaQ_hpCKoLxp-0cgxw9TqPGBSzY7RhrnFZ0jGAQ11HbOZkZ3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Royce <nroycea+kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Nathan,

On Tue, Jan 01, 2019 at 01:17:06PM -0600, Nathan Royce wrote:
> I had a leak somewhere and I was directed to look into SUnreclaim
> which was 5.5 GB after an uptime of a little over 1 month on an 8 GB
> system. kmalloc-2048 was a problem.
> I just had enough and needed to find out the cause for my lagging system.
> 
> I finally upgraded from 4.18.16 to 4.19.13 and enabled kmemleak to
> hunt for the culprit. I don't think a day had elapsed before kmemleak
> crashed and disabled itself.

Under memory pressure, kmemleak may fail to allocate memory. See this
patch for an attempt to slightly improve things but it's not a proper
solution:

http://lkml.kernel.org/r/20190102180619.12392-1-cai@lca.pw

-- 
Catalin
