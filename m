Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id A713E6B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 09:50:33 -0500 (EST)
Message-ID: <4F0EF32F.6060001@hitachi.com>
Date: Thu, 12 Jan 2012 23:50:23 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 3.2.0-rc5 9/9] perf: perf interface for uprobes
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com> <20111216122951.2085.95511.sendpatchset@srdronam.in.ibm.com> <4F06D22D.9060906@hitachi.com> <20120109112427.GB10189@linux.vnet.ibm.com>
In-Reply-To: <20120109112427.GB10189@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com

Hi Srikar,

(2012/01/09 20:24), Srikar Dronamraju wrote:
>>
>>> +
>>> +static int convert_to_perf_probe_point(struct probe_trace_point *tp,
>>> +					struct perf_probe_point *pp)
>>> +{
>>> +	pp->function = strdup(tp->symbol);
>>> +	if (pp->function == NULL)
>>> +		return -ENOMEM;
>>> +	pp->offset = tp->offset;
>>> +	pp->retprobe = tp->retprobe;
>>> +
>>> +	return 0;
>>> +}
>>
>> This function could be used in kprobe_convert_to_perf_probe() too.
>> In that case, it will be separated as a cleanup from this.
> 
> Do you really want this in a separate patch, since it doesnt make too
> much sense without the uprobes code.

If so, breaking this big patch into small pieces helps
(at least) me to review/maintain the change :)

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
