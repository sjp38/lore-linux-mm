Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 792786B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 19:09:44 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id y8so26803042igp.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 16:09:44 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.231])
        by mx.google.com with ESMTP id ug8si585551igb.89.2016.02.25.16.09.43
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 16:09:43 -0800 (PST)
Date: Thu, 25 Feb 2016 19:09:40 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] writeback: call writeback tracepoints withoud holding
 list_lock in wb_writeback()
Message-ID: <20160225190940.35553f4e@grimm.local.home>
In-Reply-To: <56CF9425.20106@linaro.org>
References: <1456354043-31420-1-git-send-email-yang.shi@linaro.org>
	<20160224214042.71c3493b@grimm.local.home>
	<56CF5848.7050806@linaro.org>
	<20160225145432.3749e5ec@gandalf.local.home>
	<56CF8B66.8070108@linaro.org>
	<20160225183107.1902d42b@gandalf.local.home>
	<56CF9288.5010406@linaro.org>
	<56CF9425.20106@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, tglx@linutronix.de, bigeasy@linutronix.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linaro-kernel@lists.linaro.org

On Thu, 25 Feb 2016 15:54:13 -0800
"Shi, Yang" <yang.shi@linaro.org> wrote:


> Can we disable irqs in tracepoints since spin_lock_irqsave is used by 
> kernfs_* functions.

Disabling preemption or irqs is fine a tracepoint. You just can't
sleep, which spin_lock_irqsave() would do on the -rt kernel.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
