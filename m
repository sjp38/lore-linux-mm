Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 290476B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 18:46:15 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so9138pdi.27
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 15:46:14 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so156299pad.2
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 15:46:12 -0700 (PDT)
Date: Tue, 1 Oct 2013 15:46:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] OOM killer: wait for tasks with pending SIGKILL to
 exit
In-Reply-To: <20131001192640.ed55682d3113b00b402bbef5@gmail.com>
Message-ID: <alpine.DEB.2.02.1310011545310.14977@chino.kir.corp.google.com>
References: <1378740624-2456-1-git-send-email-dserrg@gmail.com> <alpine.DEB.2.02.1309091303010.12523@chino.kir.corp.google.com> <20130911190605.5528ee4563272dbea1ed56a6@gmail.com> <alpine.DEB.2.02.1309251328130.24412@chino.kir.corp.google.com>
 <20130927185833.6c72b77ab105d70d4996ebef@gmail.com> <alpine.DEB.2.02.1309301457590.28109@chino.kir.corp.google.com> <20131001192640.ed55682d3113b00b402bbef5@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Rusty Russell <rusty@rustcorp.com.au>, Sha Zhengju <handai.szj@taobao.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, 1 Oct 2013, Sergey Dyasly wrote:

> If you are ok with the first change in my patch regarding fatal_signal_pending,
> I can send new patch with just that change.
> 

The entire patch is pointless, there's no need to give access to memory 
reserves simply because it is PF_EXITING.  If it needs memory, it will 
call the oom killer itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
