Message-ID: <444EF2CF.1020100@yahoo.com.au>
Date: Wed, 26 Apr 2006 14:10:55 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: serialize OOM kill operations
References: <200604251701.31899.dsp@llnl.gov>
In-Reply-To: <200604251701.31899.dsp@llnl.gov>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Peterson <dsp@llnl.gov>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Dave Peterson wrote:

>The patch below modifies the behavior of the OOM killer so that only
>one OOM kill operation can be in progress at a time.  When running a
>test program that eats lots of memory, I was observing behavior where
>the OOM killer gets impatient and shoots one or more system daemons
>in addition to the program that is eating lots of memory.  This fixes
>the problematic behavior.
>

Hi Dave,

Firstly why not use a semaphore and trylocks instead of your homebrew
lock?

Second, can you arrange it without using the extra field in mm_struct
and operation in the mmput fast path?

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
