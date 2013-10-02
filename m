Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD1E6B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 23:57:55 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so307613pbc.31
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 20:57:55 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so460516pad.19
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 20:57:52 -0700 (PDT)
Date: Tue, 1 Oct 2013 20:52:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V1] oom: avoid selecting threads sharing mm with init
In-Reply-To: <5244E7BA.4040408@windriver.com>
Message-ID: <alpine.DEB.2.02.1310012048170.10383@chino.kir.corp.google.com>
References: <1380182957-3231-1-git-send-email-ming.liu@windriver.com> <alpine.DEB.2.02.1309261143160.10904@chino.kir.corp.google.com> <5244E7BA.4040408@windriver.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Liu <ming.liu@windriver.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 27 Sep 2013, Ming Liu wrote:

> I might mislead you, when I talked about init, I meant the pid 1 process but
> not the idle, and isn't the idle a kthread and has not this risk getting
> killed by oom?

You can disqualify for p->mm == &init_mm, but the oom killer has been 
rewritten since 2.6.27 so please post a log from a recent kernel that 
exhibits the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
