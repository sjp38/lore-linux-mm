Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 318336B0082
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 21:17:10 -0500 (EST)
Received: by pdev10 with SMTP id v10so1001899pde.7
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 18:17:09 -0800 (PST)
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com. [209.85.220.47])
        by mx.google.com with ESMTPS id l1si12415622pdf.73.2015.02.06.18.17.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Feb 2015 18:17:09 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so20930133pab.6
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 18:17:08 -0800 (PST)
Message-ID: <54D575A1.60706@amacapital.net>
Date: Fri, 06 Feb 2015 18:17:05 -0800
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] mmap_sem and mm performance testing
References: <1419292284.8812.5.camel@stgolabs.net> <20150102133506.GB2395@suse.de>
In-Reply-To: <20150102133506.GB2395@suse.de>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Davidlohr Bueso <dave@stgolabs.net>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On 01/02/2015 05:35 AM, Mel Gorman wrote:
> On Mon, Dec 22, 2014 at 03:51:24PM -0800, Davidlohr Bueso wrote:
>> Hello,
>>
>> I would like to attend LSF/MM 2015. While I am very much interested in
>> general mm performance topics, I would particularly like to discuss:
>>
>> (1) Where we are at with the mmap_sem issues and progress. This topic
>> constantly comes up each year [1,2,3] without much changing. While the
>> issues are very clear (both long hold times, specially in fs paths and
>> coarse lock granularity) it would be good to detail exactly *where*
>> these problems are and what are some of the show stoppers. In addition,
>> present overall progress and benchmark numbers on fine graining via
>> range locking (I am currently working on this as a follow on to recent
>> i_mmap locking patches) and experimental work,
>> such as speculative page fault patches[4]. If nothing else, this session
>> can/should produce a list of tangible todo items.
>>
>
> There have been changes on mmap_sem hold times -- mmap_sem dropped by
> khugepaged during allocation being a very obvious one but there are
> others. The scope of what mmap_sem protects is similar but the stalling
> behaviour has changed since this was last discussed. It's worth
> revisiting where things stand and at the very least verify what cases
> are currently causing problems.
>

I think that, for my workload, the main issue is that one cpu can take 
mmap_sem and get preempted, and, since we don't have priority 
inheritance, other threads in the process get stalled.

As a terrible stopgap, some kind of priority boosting, or maybe optional 
preemption disabling for some parts of the mmap/munmap code could help. 
  The speculative page fault stuff could also help.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
