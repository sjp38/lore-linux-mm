Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 013216B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 12:22:57 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id q108so18591016qgd.1
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:22:56 -0800 (PST)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com. [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id o6si11582389qab.66.2015.01.12.09.22.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 09:22:55 -0800 (PST)
Received: by mail-qc0-f177.google.com with SMTP id x3so18979397qcv.8
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 09:22:55 -0800 (PST)
Date: Mon, 12 Jan 2015 12:22:51 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v3 5/5] oom, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20150112172251.GB22156@htj.dyndns.org>
References: <1420801555-22659-1-git-send-email-mhocko@suse.cz>
 <1420801555-22659-6-git-send-email-mhocko@suse.cz>
 <20150110194322.GE25319@htj.dyndns.org>
 <20150112161011.GE4877@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112161011.GE4877@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Mon, Jan 12, 2015 at 05:10:11PM +0100, Michal Hocko wrote:
> Yes I had it this way but it didn't work out because thaw_kernel_threads
> is not called on the resume because it is only used as a fail
> path when kernel threads freezing fails. I would rather keep the

Ooh, that's kinda asymmetric.

> enabling/disabling points as we had them. This is less risky IMHO.

Okay, please feel free to add

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
