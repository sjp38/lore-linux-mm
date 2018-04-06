Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7AAEE6B0005
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 17:36:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q22so1350466pfh.20
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 14:36:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 70-v6si9176920ple.639.2018.04.06.14.36.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 14:36:36 -0700 (PDT)
Date: Fri, 6 Apr 2018 23:36:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 199297] New: OOMs writing to files from processes with
 cgroup memory limits
Message-ID: <20180406213632.GO8286@dhcp22.suse.cz>
References: <bug-199297-27@https.bugzilla.kernel.org/>
 <20180406133600.afb9c2b0e1ba92b526f279ce@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406133600.afb9c2b0e1ba92b526f279ce@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, cbehrens@codestud.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Fri 06-04-18 13:36:00, Andrew Morton wrote:
[...]
> > Kernels before 4.11 do not see this behavior. I've tracked the issue to the
> > following commit:
> > 
> > https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit/?id=726d061fbd3658e4bfeffa1b8e82da97de2ca4dd

Thanks for the report! This should be fixed by 1c610d5f93c7 ("mm/vmscan:
wake up flushers for legacy cgroups too")

-- 
Michal Hocko
SUSE Labs
