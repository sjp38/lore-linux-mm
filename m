Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 12DAB6B019E
	for <linux-mm@kvack.org>; Thu, 14 May 2009 07:28:04 -0400 (EDT)
Subject: Re: [PATCH] Physical Memory Management [0/1]
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <op.utwwmpsf7p4s8u@amdc030>
References: <op.utu26hq77p4s8u@amdc030>
	 <20090513151142.5d166b92.akpm@linux-foundation.org>
	 <op.utwwmpsf7p4s8u@amdc030>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 14 May 2009 13:20:02 +0200
Message-Id: <1242300002.6642.1091.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-05-14 at 11:00 +0200, MichaA? Nazarewicz wrote:
>   PMM solves this problem since the buffers are allocated when they
>   are needed.

Ha - only when you actually manage to allocate things. Physically
contiguous allocations are exceedingly hard once the machine has been
running for a while.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
