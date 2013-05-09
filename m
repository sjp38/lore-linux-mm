Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id D24806B0038
	for <linux-mm@kvack.org>; Thu,  9 May 2013 09:49:24 -0400 (EDT)
Message-ID: <518BA91E.3080406@zytor.com>
Date: Thu, 09 May 2013 06:48:14 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [page fault tracepoint 1/2] Add page fault trace event definitions
References: <1368079520-11015-1-git-send-email-fdeslaur@gmail.com> <518B464E.6010208@huawei.com>
In-Reply-To: <518B464E.6010208@huawei.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhangwei(Jovi)" <jovi.zhangwei@huawei.com>
Cc: Francis Deslauriers <fdeslaur@gmail.com>, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, rostedt@goodmis.org, fweisbec@gmail.com, raphael.beamonte@gmail.com, mathieu.desnoyers@efficios.com, linux-kernel@vger.kernel.org

On 05/08/2013 11:46 PM, zhangwei(Jovi) wrote:
> On 2013/5/9 14:05, Francis Deslauriers wrote:
>> Add page_fault_entry and page_fault_exit event definitions. It will
>> allow each architecture to instrument their page faults.
> 
> I'm wondering if this tracepoint could handle other page faults,
> like faults in kernel memory(vmalloc, kmmio, etc...)
> 
> And if we decide to support those faults, add a type annotate in TP_printk
> would be much helpful for user, to let user know what type of page faults happened.
> 

The plan for x86 was to switch the IDT so that any exception could get a
trace event without any overhead in normal operation.  This has been in
the process for quite some time but looks like it was getting very close.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
