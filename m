Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49C438E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:20:38 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 82so13838237pfs.20
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 03:20:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e188sor50234025pgc.19.2019.01.28.03.20.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 03:20:37 -0800 (PST)
Date: Mon, 28 Jan 2019 22:20:33 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: [LSF/MM TOPIC] Test cases to choose for demonstrating mm features or
 fixing mm bugs
Message-ID: <20190128112033.GI26056@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Sending a patch to linux-mm today has become a complex task. One of the
reasons for the complexity is a lack of fundamental expectation of what
tests to run.

Mel Gorman has a set of tests [1], but there is no easy way to select
what tests to run. Some of them are proprietary (spec*), but others
have varying run times. A single line change may require hours or days
of testing, add to that complexity of configuration. It requires a lot
of tweaking and frequent test spawning to settle down on what to run,
what configuration to choose and benefit to show.

The proposal is to have a discussion on how to design a good sanity
test suite for the mm subsystem, which could potentially include
OOM test cases and known problem patterns with proposed changes

It would be great if we could discuss that in the summit this time,
all members are welcome and encouraged to participate.


References:

[1] https://github.com/gormanm/mmtests
