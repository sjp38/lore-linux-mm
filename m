Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 13EDD6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 20:21:54 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id gq1so16702356obb.9
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:21:53 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y4si897400obm.66.2015.01.15.17.21.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 17:21:53 -0800 (PST)
Message-ID: <54B867A8.6050900@oracle.com>
Date: Thu, 15 Jan 2015 20:21:44 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Reclaim in the face of really fast I/O
References: <54B82A57.9060000@intel.com>
In-Reply-To: <54B82A57.9060000@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, lsf-pc@lists.linux-foundation.org, "Reddy, Dheeraj" <dheeraj.reddy@intel.com>
Cc: "Kleen, Andi" <andi.kleen@intel.com>, Linux-MM <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>

On 01/15/2015 04:00 PM, Dave Hansen wrote:
> I/O devices are only getting faster.  In fact, they're getting closer
> and closer to memory in latency and bandwidth.  But the VM is still
> designed to do very orderly and costly procedures to reclaim memory, and
> the existing algorithms don't parallelize particularly well.  They hit
> contention on mmap_sem or the lru locks well before all of the CPU
> horsepower that we have can be brought to bear on reclaim.
> 
> Once the latency to bring pages in and out of storage becomes low
> enough, reclaiming the _right_ pages becomes much less important than
> doing something useful with the CPU horsepower that we have.
> 
> We need to talk about ways to do reclaim with lower CPU overhead and to
> parallelize more effectively.
> 
> There has been some research in this area by some folks at Intel and we
> could quickly summarize what has been learned so far to help kick off a
> discussion.

I was actually planning to bring that up. Trinity can cause enough stress
to a system that the hang watchdog triggers (with a 10 minute timeout!)
inside reclaim code.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
