Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1296B006C
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 10:42:13 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id w55so29899339wes.4
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 07:42:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id pi1si22961819wjb.94.2015.02.16.07.42.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Feb 2015 07:42:11 -0800 (PST)
Date: Mon, 16 Feb 2015 10:42:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150216154201.GA27295@phnom.home.cmpxchg.org>
References: <20141220223504.GI15665@dastard>
 <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
 <20141230112158.GA15546@dhcp22.suse.cz>
 <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Mon, Feb 16, 2015 at 08:23:16PM +0900, Tetsuo Handa wrote:
>   (2) Implement TIF_MEMDIE timeout.

How about something like this?  This should solve the deadlock problem
in the page allocator, but it would also simplify the memcg OOM killer
and allow its use by in-kernel faults again.

--
