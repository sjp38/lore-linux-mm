Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2168E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:34:45 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so6422260edr.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 03:34:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f20si4549066ejb.273.2019.01.28.03.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 03:34:43 -0800 (PST)
Date: Mon, 28 Jan 2019 12:34:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Test cases to choose for demonstrating mm
 features or fixing mm bugs
Message-ID: <20190128113442.GG18811@dhcp22.suse.cz>
References: <20190128112033.GI26056@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128112033.GI26056@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Mon 28-01-19 22:20:33, Balbir Singh wrote:
> Sending a patch to linux-mm today has become a complex task. One of the
> reasons for the complexity is a lack of fundamental expectation of what
> tests to run.
> 
> Mel Gorman has a set of tests [1], but there is no easy way to select
> what tests to run. Some of them are proprietary (spec*), but others
> have varying run times. A single line change may require hours or days
> of testing, add to that complexity of configuration. It requires a lot
> of tweaking and frequent test spawning to settle down on what to run,
> what configuration to choose and benefit to show.
> 
> The proposal is to have a discussion on how to design a good sanity
> test suite for the mm subsystem, which could potentially include
> OOM test cases and known problem patterns with proposed changes

I am not sure I follow. So what is the problem you would like to solve.
If tests are taking too long then there is a good reason for that most
probably. Are you thinking of any specific tests which should be run or
even included to MM tests or similar?
-- 
Michal Hocko
SUSE Labs
