Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD068E00C8
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:51:59 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so3431087edq.4
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 00:51:59 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f52si2393592ede.346.2019.01.25.00.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 00:51:57 -0800 (PST)
Date: Fri, 25 Jan 2019 09:51:56 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: BUG() due to "mm: put_and_wait_on_page_locked() while page is
 migrated"
Message-ID: <20190125085156.GH3560@dhcp22.suse.cz>
References: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw>
 <20190123093002.GP4087@dhcp22.suse.cz>
 <alpine.LSU.2.11.1901241909180.2158@eggly.anvils>
 <921c752d-8806-b9b5-8bb6-d570a3fec33d@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <921c752d-8806-b9b5-8bb6-d570a3fec33d@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, vbabka@suse.cz, akpm@linux-foundation.org, Linux-MM <linux-mm@kvack.org>

On Thu 24-01-19 23:31:46, Qian Cai wrote:
[...]
> It looks like the put_and_wait commit just make the bug easier to reproduce, as
> it has finally been able to reproduce it (via a different path) after 50+ runs
> of migrate_pages03 on one of the affected machines even with the commit reverted.

OK, great. This makes it a little bit less of a head scratcher then.
Could you confirm whether this is FS specific please? I will go and
check the migration path. Maybe we doing something wrong there but it
would be definitely good to know whether the underlying fs is really
relevant. Thanks!
-- 
Michal Hocko
SUSE Labs
