Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C411F6B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 23:41:06 -0400 (EDT)
Message-ID: <4DEEEF4C.2000404@hitachi.com>
Date: Wed, 08 Jun 2011 12:41:00 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3.0-rc2-tip 20/22] 20: perf: perf interface for	uprobes
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6> <20110607133039.GA4929@infradead.org> <20110607133853.GC9949@in.ibm.com>
In-Reply-To: <20110607133853.GC9949@in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ananth@in.ibm.com
Cc: Christoph Hellwig <hch@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

(2011/06/07 22:38), Ananth N Mavinakayanahalli wrote:
> On Tue, Jun 07, 2011 at 09:30:39AM -0400, Christoph Hellwig wrote:
>> On Tue, Jun 07, 2011 at 06:32:16PM +0530, Srikar Dronamraju wrote:
>>>
>>> Enhances perf probe to user space executables and libraries.
>>> Provides very basic support for uprobes.
>>
>> Nice.  Does this require full debug info for symbolic probes,
>> or can it also work with simple symbolc information?
> 
> It works only with symbol information for now.
> It doesn't (yet) know how to use debuginfo :-)

So we can enhance it to use debuginfo for obtaining
variables or line numbers from debuginfo. since
probe-finder already has the analysis part, I think
it's not hard to support userspace apps.

Thanks!

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
