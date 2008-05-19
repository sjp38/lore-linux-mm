From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: bootmem: Double freeing a PFN on nodes spanning other nodes
References: <87skwhyj8g.fsf@saeurebad.de>
	<20080519093525.4867bfb4.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 19 May 2008 03:31:10 +0200
In-Reply-To: <20080519093525.4867bfb4.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Mon, 19 May 2008 09:35:25 +0900")
Message-ID: <87d4njulk1.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Sat, 17 May 2008 00:30:55 +0200
> Johannes Weiner <hannes@saeurebad.de> wrote:
>
>> Hi,
>> 
>> When memory nodes overlap each other, the bootmem allocator is not aware
>> of this and might pass the same page twice to __free_pages_bootmem().
>> 
>
> 1. init_bootmem_node() is called against a node, [start, end). After this,
>    all pages are 'allocated'.
> 2. free_bootmem_node() is called against available memory in a node.
> 3. bootmem allocator is ready.
>
> memory overlap seems not to be trouble while an arch's code calls
> free_bootmem_node() correctly.

Ah, I totally overlooked that one.  Thank you very much!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
