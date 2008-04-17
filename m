From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC][patch 0/5] Bootmem fixes
References: <20080416113629.947746497@skyscraper.fehenstaub.lan>
	<20080417183639.7d3831e0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 17 Apr 2008 12:49:27 +0200
In-Reply-To: <20080417183639.7d3831e0.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Thu, 17 Apr 2008 18:36:39 +0900")
Message-ID: <87lk3ceoy0.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Wed, 16 Apr 2008 13:36:29 +0200
> Johannes Weiner <hannes@saeurebad.de> wrote:
>
>> Hi,
>> 
>> here are a bunch of fixes for the bootmem allocator.  These are tested
>> on boring x86_32 UMA hardware, but 3 patches only show their effects
>> on multi-node systems, so please review and test.
>> 
>> Only the first two patches are real code changes, the others are
>> cleanups.
>> 
>> `Node-setup agnostic free_bootmem()' assumes that all bootmem
>> descriptors describe contiguous regions and bdata_list is in ascending
>> order.  Yinghai was unsure about this fact, Ingo could you ACK/NAK
>> this?
>> 
> Tested on ia64/NUMA box  on 2.6.25. seems no problem.

Cool, thanks a lot!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
