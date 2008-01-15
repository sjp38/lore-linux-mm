Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m0FHrhtf010511
	for <linux-mm@kvack.org>; Tue, 15 Jan 2008 09:53:43 -0800
Received: from py-out-1112.google.com (pygy77.prod.google.com [10.34.226.77])
	by zps78.corp.google.com with ESMTP id m0FHrP1S029952
	for <linux-mm@kvack.org>; Tue, 15 Jan 2008 09:53:43 -0800
Received: by py-out-1112.google.com with SMTP id y77so2837409pyg.28
        for <linux-mm@kvack.org>; Tue, 15 Jan 2008 09:53:43 -0800 (PST)
Message-ID: <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com>
Date: Tue, 15 Jan 2008 09:53:42 -0800
From: "Michael Rubin" <mrubin@google.com>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
In-Reply-To: <1200386774.15103.20.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080115080921.70E3810653@localhost>
	 <1200386774.15103.20.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Jan 15, 2008 12:46 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Just a quick question, how does this interact/depend-uppon etc.. with
> Fengguangs patches I still have in my mailbox? (Those from Dec 28th)

They don't. They apply to a 2.6.24rc7 tree. This is a candidte for 2.6.25.

This work was done before Fengguang's patches. I am trying to test
Fengguang's for comparison but am having problems with getting mm1 to
boot on my systems.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
