Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 086236B00AF
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 11:12:16 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id q108so956329qgd.7
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:12:15 -0800 (PST)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id v9si7086604qat.45.2014.11.06.08.12.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 08:12:14 -0800 (PST)
Received: by mail-qc0-f176.google.com with SMTP id x3so1013495qcv.7
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:12:14 -0800 (PST)
Date: Thu, 6 Nov 2014 11:12:11 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106161211.GC25642@htj.dyndns.org>
References: <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105170111.GG14386@htj.dyndns.org>
 <20141106130543.GE7202@dhcp22.suse.cz>
 <20141106150927.GB25642@htj.dyndns.org>
 <20141106160158.GI7202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106160158.GI7202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Thu, Nov 06, 2014 at 05:01:58PM +0100, Michal Hocko wrote:
> Yes, OOM killer simply kicks the process sets TIF_MEMDIE and terminates.
> That will release the read_lock, allow this to take the write lock and
> check whether it the current has been killed without any races.
> OOM killer doesn't wait for the killed task. The allocation is retried.
> 
> Does this explain your concern?

Draining oom killer then doesn't mean anything, no?  OOM killer may
have been disabled and drained but the killed tasks might wake up
after the PM freezer considers them to be frozen, right?  What am I
missing?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
