Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9D36B006E
	for <linux-mm@kvack.org>; Sat,  6 Dec 2014 08:09:35 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id z60so1715304qgd.34
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 05:09:34 -0800 (PST)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com. [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id g75si37966998qge.83.2014.12.06.05.09.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 06 Dec 2014 05:09:34 -0800 (PST)
Received: by mail-qa0-f49.google.com with SMTP id s7so1598624qap.22
        for <linux-mm@kvack.org>; Sat, 06 Dec 2014 05:09:34 -0800 (PST)
Date: Sat, 6 Dec 2014 08:09:31 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v2 4/5] sysrq: convert printk to pr_* equivalent
Message-ID: <20141206130931.GE18711@htj.dyndns.org>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-5-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417797707-31699-5-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Fri, Dec 05, 2014 at 05:41:46PM +0100, Michal Hocko wrote:
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
