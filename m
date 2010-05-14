Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B5B946B0203
	for <linux-mm@kvack.org>; Fri, 14 May 2010 03:38:20 -0400 (EDT)
Message-ID: <4BECFDE9.2080301@linux.intel.com>
Date: Fri, 14 May 2010 15:38:17 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC,2/7] NUMA Hotplug emulator
References: <20100513114544.GC2169@shaohui> <20100514111615.c7ca63a5.kamezawa.hiroyu@jp.fujitsu.com> <20100514054226.GB12002@linux-sh.org>
In-Reply-To: <20100514054226.GB12002@linux-sh.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Shaohui Zheng <shaohui.zheng@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

Paul Mundt wrote:
> On Fri, May 14, 2010 at 11:16:15AM +0900, KAMEZAWA Hiroyuki wrote:
>> On Thu, 13 May 2010 19:45:44 +0800
>> Shaohui Zheng <shaohui.zheng@intel.com> wrote:
>>
>>> x86: infrastructure of NUMA hotplug emulation
>>>
>> Hmm. do we have to create this for x86 only ?
>> Can't we live with lmb ? as
>>
>> 	lmb_hide_node() or some.
>>
>> IIUC, x86-version lmb is now under development.
>>
> Indeed. There is very little x86-specific about this patch series at all
> except for the e820 bits and tying in the CPU topology. Most of what this
> series is doing wrapping around e820 could be done on top of LMB, which
> would also make it possible to use on non-x86 architectures.

Hmm, we'll evaluate it. We'd like to make it support non-x86 archs if LMB is a feasible way.
Thank you, Kame and Paul.

-haicheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
