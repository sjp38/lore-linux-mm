Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 32A516B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 19:08:46 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so68320085igb.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:08:46 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id s20si150529ioe.199.2015.09.21.16.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 16:08:44 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so131813248pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:08:44 -0700 (PDT)
Date: Mon, 21 Sep 2015 16:08:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
In-Reply-To: <20150919082237.GB28815@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1509211607260.27715@chino.kir.corp.google.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919082237.GB28815@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 19 Sep 2015, Michal Hocko wrote:

> Nack to this. TASK_UNINTERRUPTIBLE should be time constrained/bounded
> state. Using it as an oom victim criteria makes the victim selection
> less deterministic which is undesirable. As much as I am aware of
> potential issues with the current implementation, making the behavior
> more random doesn't really help.
> 

Agreed, we can't avoid killing a process simply because it is in D state, 
this isn't an indication that the process will not be able to exit and in 
the worst case could panic the system if all other processes cannot be oom 
killed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
