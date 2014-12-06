Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 81A386B0032
	for <linux-mm@kvack.org>; Sat,  6 Dec 2014 08:08:30 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id r5so1762602qcx.30
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 05:08:30 -0800 (PST)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com. [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id s104si27451209qge.78.2014.12.06.05.08.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 06 Dec 2014 05:08:29 -0800 (PST)
Received: by mail-qa0-f43.google.com with SMTP id bm13so1603405qab.2
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 05:08:29 -0800 (PST)
Date: Sat, 6 Dec 2014 08:08:26 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v2 3/5] PM: convert printk to pr_* equivalent
Message-ID: <20141206130826.GD18711@htj.dyndns.org>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417797707-31699-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Fri, Dec 05, 2014 at 05:41:45PM +0100, Michal Hocko wrote:
> While touching this area let's convert printk to pr_*. This also makes
> the printing of continuation lines done properly.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
