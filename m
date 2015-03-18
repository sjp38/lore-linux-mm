Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36A1E6B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 20:55:05 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so25219534pad.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 17:55:05 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.231])
        by mx.google.com with ESMTP id bu12si32514481pdb.92.2015.03.17.17.55.03
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 17:55:04 -0700 (PDT)
Date: Tue, 17 Mar 2015 20:55:55 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] tracing: add trace event for memory-failure
Message-ID: <20150317205555.207b0605@grimm.local.home>
In-Reply-To: <5508064C.7090707@huawei.com>
References: <1426241451-25729-1-git-send-email-xiexiuqi@huawei.com>
	<CA+8MBbKen9JfQ29AWVZuxO9CkPCmjG670q0Fg7G-qCPDrtDHig@mail.gmail.com>
	<20150313153210.14f1bd88@gandalf.local.home>
	<5508064C.7090707@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: Tony Luck <tony.luck@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Chen Gong <gong.chen@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Borislav Petkov <bp@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jingle.chen@huawei.com

On Tue, 17 Mar 2015 18:47:40 +0800
Xie XiuQi <xiexiuqi@huawei.com> wrote:

> I'm not clearly why we need a hard coded here. As the strings or "result" have
> defined in mm/memory-failure.c, so passing "action_name[result]" would be more
> clean and more flexible here?

The TP_printk() is what will be shown in the print format of the event
"format" file, and is what trace-cmd and perf use to parse the data and
know what to print. If you use "action_name[result]" that will be what
the user space tools see, and will have no idea what to do with
"action_name[result]". The hard coded output is a bit more explicit in
how to interpret the raw data.

Another way around this is to create a "plugin" that can be loaded and
will override the TP_printk() parsing.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
