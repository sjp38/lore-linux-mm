Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 684CC6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 20:57:41 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so58779487pac.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 17:57:41 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id iw5si18071356pbc.27.2015.06.25.17.57.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 17:57:40 -0700 (PDT)
Received: by pdbci14 with SMTP id ci14so63762753pdb.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 17:57:39 -0700 (PDT)
Date: Fri, 26 Jun 2015 09:58:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: extremely long blockages when doing random writes to SSD
Message-ID: <20150626005808.GA5704@swordfish>
References: <CAA25o9SCnDYZ6vXWQWEWGDiwpV9rf+S_3Np8nJrWqHJ1x6-kMg@mail.gmail.com>
 <20150624152518.d3a5408f2bde405df1e6e5c4@linux-foundation.org>
 <CAA25o9RNLr4Gk_4m56bAf7_RBsObrccFWPtd-9jwuHg1NLdRTA@mail.gmail.com>
 <CAA25o9ShiKyPTBYbVooA=azb+XO9PWFtididoyPa4s-v56mvBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9ShiKyPTBYbVooA=azb+XO9PWFtididoyPa4s-v56mvBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hello,

On (06/25/15 11:24), Luigi Semenzato wrote:
> I looked at this some more and I am not sure that there is any bug, or
> other possible tuning.
> 
> While the random-write process runs, iostat -x -k 1 reports these numbers:
> 
> average queue size: around 300
> average write wait: typically 200 to 400 ms, but can be over 1000 ms
> average read wait: typically 50 to 100 ms
> 
> (more info at crbug.com/414709)
> 
> The read latency may be enough to explain the jank.  In addition, the
> browser can do fsyncs, and I think that those will block for a long
> time.
> 
> Ionice doesn't seem to make a difference.  I suspect that once the
> blocks are in the output queue, it's first-come/first-serve.  Is this
> correct or am I confused?
> 
> We can fix this on the application side but only partially.  The OS
> version updater can use O_SYNC.  The problem is that his can happen in
> a number of situations, such as when simply downloading a large file,
> and in other code we don't control.
> 

do you use CONFIG_IOSCHED_DEADLINE or CONFIG_IOSCHED_CFQ?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
