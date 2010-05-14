Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 184046B01EE
	for <linux-mm@kvack.org>; Fri, 14 May 2010 01:43:19 -0400 (EDT)
Date: Fri, 14 May 2010 14:42:26 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC,2/7] NUMA Hotplug emulator
Message-ID: <20100514054226.GB12002@linux-sh.org>
References: <20100513114544.GC2169@shaohui> <20100514111615.c7ca63a5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100514111615.c7ca63a5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Shaohui Zheng <shaohui.zheng@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 11:16:15AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 13 May 2010 19:45:44 +0800
> Shaohui Zheng <shaohui.zheng@intel.com> wrote:
> 
> > x86: infrastructure of NUMA hotplug emulation
> > 
> 
> Hmm. do we have to create this for x86 only ?
> Can't we live with lmb ? as
> 
> 	lmb_hide_node() or some.
> 
> IIUC, x86-version lmb is now under development.
> 
Indeed. There is very little x86-specific about this patch series at all
except for the e820 bits and tying in the CPU topology. Most of what this
series is doing wrapping around e820 could be done on top of LMB, which
would also make it possible to use on non-x86 architectures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
