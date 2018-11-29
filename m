Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 381A96B5487
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 15:54:28 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so1680652edm.18
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 12:54:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x23-v6si1290891ejc.139.2018.11.29.12.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 12:54:27 -0800 (PST)
Date: Thu, 29 Nov 2018 21:54:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Question about the laziness of MADV_FREE
Message-ID: <20181129205423.GA6923@dhcp22.suse.cz>
References: <47407223-2fa2-2721-c6c3-1c1659dc474e@nh2.me>
 <20181129180057.GZ6923@dhcp22.suse.cz>
 <1423043c-af4b-0288-9f42-e00be320491b@nh2.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1423043c-af4b-0288-9f42-e00be320491b@nh2.me>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Niklas =?iso-8859-1?Q?Hamb=FCchen?= <mail@nh2.me>
Cc: linux-mm@kvack.org

On Thu 29-11-18 20:21:49, Niklas Hamb�chen wrote:
> Hello Michal,
> 
> thanks for the swift reply and patch!
> 
> > We batch multiple pages to become really lazyfree. This means that those
> > pages are sitting on a per-cpu list (see mark_page_lazyfree). So the
> > the number drift depends on the number of CPUs.
> 
> Is there an upper bound that I can rely on in order to judge how far off the accounting is (perhaps depending on the number of CPUs as you say)?
> For example, if the drift is bounded to, say 10%, that would probably be fine, while if it could be off by 2x or so, that would make system inspection tough.

>From a quick look it should be 15*number_of_cpus unless I have missed
other caching. So this shouldn't be all that much unless you have a
giant machine with hundreds of cpus.
-- 
Michal Hocko
SUSE Labs
