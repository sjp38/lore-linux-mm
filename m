From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/2] panics booting NUMA SPARSEMEM on x86_32 NUMA 
Message-ID: <exportbomb.1211277639@pinky>
Date: Tue, 20 May 2008 11:00:57 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

We have been seeing panics booting NUMA SPARSEMEM kernels on x86_32
hardware, while trying to allocate node local memory in early boot.
These are caused by a miss-allocation of the node pgdat structures when
numa remap is disabled.

Following this email are two patches, the first reenables numa remap for
SPARSEMEM as the underlying bug has now been fixed.  The second hardens
the pgdat allocation in the face of there being no numa remap for a
particular node (which may still occur).

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
