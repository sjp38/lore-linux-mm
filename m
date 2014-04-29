Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF8A6B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 04:22:30 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id z10so5937603pdj.33
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 01:22:30 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id qe5si12163200pbc.152.2014.04.29.01.22.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 01:22:29 -0700 (PDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 29 Apr 2014 18:22:26 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D60F42CE8060
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 18:22:23 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3T8M8337995694
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 18:22:09 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3T8MMsi005500
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 18:22:22 +1000
Message-ID: <535F610F.6090705@linux.vnet.ibm.com>
Date: Tue, 29 Apr 2014 13:51:35 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
References: <535EA976.1080402@linux.vnet.ibm.com> <20140429000031.GA4284@redhat.com>
In-Reply-To: <20140429000031.GA4284@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, davidlohr@hp.com, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 04/29/2014 05:30 AM, Dave Jones wrote:
> On Tue, Apr 29, 2014 at 12:48:14AM +0530, Srivatsa S. Bhat wrote:
>  > Hi,
>  > 
>  > I hit this during boot on v3.15-rc3, just once so far.
>  > Subsequent reboots went fine, and a few quick runs of multi-
>  > threaded ebizzy also didn't recreate the problem.
>  > 
>  > The kernel I was running was v3.15-rc3 + some totally
>  > unrelated cpufreq patches.
> 
> Could you post those patches somewhere ?
> They may not be directly related to the code in the trace, but if
> they are randomly corrupting memory, maybe that would explain things ?
>

Why post them just 'somewhere'? I posted them on LKML! :-)

This is the patchset I was testing:  :-)

https://lkml.org/lkml/2014/4/28/473

Regards,
Srivatsa S. Bhat


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
