Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D90B78E00D7
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 22:17:20 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 80so11624280qkd.0
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 19:17:20 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u42sor128265530qtk.23.2019.01.25.19.17.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 19:17:19 -0800 (PST)
Subject: Re: BUG() due to "mm: put_and_wait_on_page_locked() while page is
 migrated"
References: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw>
 <20190123093002.GP4087@dhcp22.suse.cz>
 <alpine.LSU.2.11.1901241909180.2158@eggly.anvils>
 <921c752d-8806-b9b5-8bb6-d570a3fec33d@lca.pw>
 <20190125085156.GH3560@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <5bf18231-4039-10ad-4d2b-cac856a998c3@lca.pw>
Date: Fri, 25 Jan 2019 22:17:17 -0500
MIME-Version: 1.0
In-Reply-To: <20190125085156.GH3560@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, vbabka@suse.cz, akpm@linux-foundation.org, Linux-MM <linux-mm@kvack.org>



On 1/25/19 3:51 AM, Michal Hocko wrote:
> On Thu 24-01-19 23:31:46, Qian Cai wrote:
> [...]
>> It looks like the put_and_wait commit just make the bug easier to reproduce, as
>> it has finally been able to reproduce it (via a different path) after 50+ runs
>> of migrate_pages03 on one of the affected machines even with the commit reverted.
> 
> OK, great. This makes it a little bit less of a head scratcher then.
> Could you confirm whether this is FS specific please? I will go and
> check the migration path. Maybe we doing something wrong there but it
> would be definitely good to know whether the underlying fs is really
> relevant. Thanks!
> 

So, I reinstalled everything using an ext4 rootfs, and then it becomes
impossible to reproduce it anymore...
