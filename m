Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2A966B006A
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 14:21:01 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id n8OIJk58001516
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:19:46 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8OIL5tn868464
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:21:05 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8OIL5g7006468
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:21:05 +1000
Message-ID: <4ABBB88A.5000200@linux.vnet.ibm.com>
Date: Thu, 24 Sep 2009 23:50:58 +0530
From: Rishikesh <risrajak@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com> <4ABB6EB6.2040204@linux.vnet.ibm.com> <878wg41f65.fsf@caffeine.danplanet.com>
In-Reply-To: <878wg41f65.fsf@caffeine.danplanet.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Dan Smith <danms@us.ibm.com>
Cc: Oren Laadan <orenl@librato.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dan Smith wrote:
> R> I am getting following build error while compiling linux-cr kernel.
>
> With CONFIG_CHECKPOINT=n, right?
>
> R> 76569 net/unix/af_unix.c:528: error: a??unix_collecta?? undeclared here (not 
> R> in a function)
>
> Try the patch below.
>   

Yes attached patch solves the prob. Thanks Dan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
