Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id EE88E6B0036
	for <linux-mm@kvack.org>; Mon, 13 May 2013 11:08:20 -0400 (EDT)
Message-ID: <1368457698.6828.34.camel@gandalf.local.home>
Subject: Re: [page fault tracepoint 1/2] Add page fault trace event
 definitions
From: Steven Rostedt <rostedt@goodmis.org>
Date: Mon, 13 May 2013 11:08:18 -0400
In-Reply-To: <20130513112132.GA15168@Krystal>
References: <1368079520-11015-1-git-send-email-fdeslaur@gmail.com>
	 <518B464E.6010208@huawei.com> <518BA91E.3080406@zytor.com>
	 <20130513112132.GA15168@Krystal>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, "zhangwei(Jovi)" <jovi.zhangwei@huawei.com>, Francis Deslauriers <fdeslaur@gmail.com>, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, fweisbec@gmail.com, raphael.beamonte@gmail.com, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Seiji Aguchi <seiji.aguchi@hds.com>

On Mon, 2013-05-13 at 07:21 -0400, Mathieu Desnoyers wrote:
> * H. Peter Anvin (hpa@zytor.com) wrote:

> Who is leading this IDT instrumentation effort ?
> 

Seiji has been doing most of the work. I've just been busy doing other
things but I need to start getting this tidied up, and hopefully this
can get into 3.11.

https://lkml.org/lkml/2013/4/5/401

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
