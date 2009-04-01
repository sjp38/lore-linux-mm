Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B53346B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 11:33:36 -0400 (EDT)
Message-ID: <49D38967.8020706@redhat.com>
Date: Wed, 01 Apr 2009 11:33:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 5/6] Guest page hinting: minor fault optimization.
References: <20090327150905.819861420@de.ibm.com> <20090327151012.713478499@de.ibm.com>
In-Reply-To: <20090327151012.713478499@de.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:
> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> From: Hubertus Franke <frankeh@watson.ibm.com>
> From: Himanshu Raj
> 
> On of the challenges of the guest page hinting scheme is the cost for
> the state transitions. If the cost gets too high the whole concept of
> page state information is in question. Therefore it is important to
> avoid the state transitions when possible. 

> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
