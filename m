Date: Thu, 16 Jan 2003 00:14:47 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] make vm_enough_memory more efficient
Message-Id: <20030116001447.07337e9e.akpm@digeo.com>
In-Reply-To: <66360000.1042703224@titus>
References: <66360000.1042703224@titus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> vm_enough_memory seems to call si_meminfo just to get the total 
> RAM, which seems far too expensive. This replaces the comment
> saying "this is crap" with some code that's less crap.
> 
> Not heavily tested (compiles and boots), but seems pretty obvious.

Yup, obviously correct.

The really hurtful part of vm_enough_memory() is the call to
get_page_cache_size(), which has to go over every CPU's local VM statistics
in get_page_state().

But I guess you're running with sysctl_overcommit_memory != 0.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
