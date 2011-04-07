Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 432BE8D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 23:19:15 -0400 (EDT)
Message-ID: <4D9D2D28.4040508@hitachi.com>
Date: Thu, 07 Apr 2011 12:19:04 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2.6.39-rc1-tip 26/26] 26: uprobes: filter chain
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6> <20110401143737.15455.30181.sendpatchset@localhost6.localdomain6> <4D9A6FE8.2010301@hitachi.com> <20110406224148.GA5806@linux.vnet.ibm.com>
In-Reply-To: <20110406224148.GA5806@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>

(2011/04/07 7:41), Srikar Dronamraju wrote:
>>> +static bool filter_chain(struct uprobe *uprobe, struct task_struct *t)
>>> +{
>>> +	struct uprobe_consumer *consumer;
>>> +	bool ret = false;
>>> +
>>> +	down_read(&uprobe->consumer_rwsem);
>>> +	for (consumer = uprobe->consumers; consumer;
>>> +					consumer = consumer->next) {
>>> +		if (!consumer->filter || consumer->filter(consumer, t)) {
>>> +			ret = true;
>>> +			break;
>>> +		}
>>> +	}
>>> +	up_read(&uprobe->consumer_rwsem);
>>> +	return ret;
>>> +}
>>> +
>>
>> Where this function is called from ? This patch seems the last one of this series...
>>
> 
> Sorry for the delayed reply, I was travelling to LFCS.
> Still I have to connect the filter from trace/perf probe. 

I see, and I'd like to suggest you to separate that series
from this "uprobe" series. For upstream merge, indeed, we
need a consumer of the uprobe. However, it should be as simple
as possible, so that we can focus on reviewing uprobe itself.

> Thats listed as todo and thats the next thing I am planning to work on.

Interesting:) Could you tell us what the plan will introduce?
How will it be connected? how will we use it?

Thank you,

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
