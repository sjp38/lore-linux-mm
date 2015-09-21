Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 11D296B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:40:55 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so103080457wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:40:54 -0700 (PDT)
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com. [195.75.94.105])
        by mx.google.com with ESMTPS id ex3si15497124wic.6.2015.09.21.00.40.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Sep 2015 00:40:33 -0700 (PDT)
Received: from /spool/local
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 21 Sep 2015 08:40:23 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6BB07219006A
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:39:52 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8L7eLkb38993920
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:40:21 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8L7eLOF008443
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 01:40:21 -0600
Date: Mon, 21 Sep 2015 09:40:19 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150921094019.6b311a9b@mschwide>
In-Reply-To: <20150921073033.GA3181@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
	<1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
	<20150917193152.GJ2000@uranus>
	<20150918085835.597fb036@mschwide>
	<20150918071549.GA2035@uranus>
	<20150918102001.0e0389c7@mschwide>
	<20150918085301.GC2035@uranus>
	<20150918111038.58c3a8de@mschwide>
	<20150918202109.GE2035@uranus>
	<20150921091033.1799ea40@mschwide>
	<20150921073033.GA3181@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, 21 Sep 2015 10:30:33 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Mon, Sep 21, 2015 at 09:10:33AM +0200, Martin Schwidefsky wrote:
> > > 
> > > Agreed, still I would defer until there is a real need for an alternative encoding.
> > 
> > The s390 support for soft dirty ptes will need it.
> 
> Ah, I see. Could you please note this fact in the patch
> changelog.
 
Sure will do. I'll send a patch set after I got the x86 test sorted out.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
