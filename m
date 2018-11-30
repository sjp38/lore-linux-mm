Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C18696B5731
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 03:19:26 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so2438447edd.11
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 00:19:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg5-v6si1922575ejb.288.2018.11.30.00.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 00:19:25 -0800 (PST)
Date: Fri, 30 Nov 2018 09:19:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Question about the laziness of MADV_FREE
Message-ID: <20181130081924.GD6923@dhcp22.suse.cz>
References: <47407223-2fa2-2721-c6c3-1c1659dc474e@nh2.me>
 <20181129180057.GZ6923@dhcp22.suse.cz>
 <1423043c-af4b-0288-9f42-e00be320491b@nh2.me>
 <20181129205423.GA6923@dhcp22.suse.cz>
 <42c6c45c-f918-211f-c428-cd45416615df@nh2.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <42c6c45c-f918-211f-c428-cd45416615df@nh2.me>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Niklas =?iso-8859-1?Q?Hamb=FCchen?= <mail@nh2.me>
Cc: linux-mm@kvack.org

On Fri 30-11-18 00:00:26, Niklas Hamb�chen wrote:
> On 2018-11-29 21:54, Michal Hocko wrote:
> > From a quick look it should be 15*number_of_cpus unless I have missed
> > other caching. So this shouldn't be all that much unless you have a
> > giant machine with hundreds of cpus.
> 
> For clarfication, is that 15*number_of_cpus many pages, or "factor" 15*number_of_cpu off what LazyFree reports?

The number of pages.

-- 
Michal Hocko
SUSE Labs
