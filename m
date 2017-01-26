Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4CCB6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 11:06:23 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 75so317199931pgf.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:06:23 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0137.outbound.protection.outlook.com. [104.47.0.137])
        by mx.google.com with ESMTPS id e11si1758896plj.120.2017.01.26.08.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 08:06:22 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] userfaultfd
References: <20170126130831.GA28055@rapoport-lnx>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <588A1F92.6010405@virtuozzo.com>
Date: Thu, 26 Jan 2017 19:10:58 +0300
MIME-Version: 1.0
In-Reply-To: <20170126130831.GA28055@rapoport-lnx>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

On 01/26/2017 04:08 PM, Mike Rapoport wrote:
> Hello,
> 
> I'm working on integration of userfaultfd into CRIU. Currently we can
> perform lazy restore and post-copy migration with the help of
> userfaultfd, but there are some limitations because of incomplete
> in-kernel support for non-cooperative mode of userfaultfd.
> 
> I'd like to particpate in userfaultfd-WP discussion suggested by
> Andrea Acangeli [1].

I'd like to support Mike's "self-nomination".

-- Pavel

> Besides, I would like to broaden userfaultfd discussion so it will
> also cover the following topics:
> 
> * Non-cooperative userfaultfd APIs for checkpoint/restore
> 
> Checkpoint/restore of an application that uses userfaultfd will
> require additions to the userfaultfd API. The new APIs are needed to
> allow saving parts of in-kernel state of userfaultfd during checkpoint
> and then recreating this state during restore.
> 
> * Userfaultfd and COW-sharing.
> 
> If we have two tasks that fork()-ed from each other and we try to
> lazily restore a page that is still COW-ed between them, the uffd API
> doesn't give us anything to do it. So we effectively break COW on lazy
> restore.
> 
> * Userfaultfd "nesting" [2]
> 
> CRIU uses soft-dirty to track memory changes. We would like to switch
> to userfaultfd-WP once it gets merged. If the process for which we are
> tracking memory changes uses userfaultfd, we would need some notion of
> uffd "nesting", so that the same memory region could be monitored by
> different userfault file descriptors. Even more interesting case is
> tracking memory changes of two different processes: one process that
> has memory regions monitored by uffd and another one that owns the
> non-cooperative userfault file descriptor to monitor the first
> process.
> The userfaultfd "nesting" is also required for lazy restore scenario so
> that CRIU will be able to use userfaultfd for memory ranges that the
> restored application is already managing with userfaultfd.
> 
> [1] http://www.spinics.net/lists/linux-mm/msg119866.html
> [2] https://www.spinics.net/lists/linux-mm/msg112500.html
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
