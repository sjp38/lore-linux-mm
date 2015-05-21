Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id C88C96B015B
	for <linux-mm@kvack.org>; Thu, 21 May 2015 09:01:56 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so9236867igb.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 06:01:56 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0222.hostedemail.com. [216.40.44.222])
        by mx.google.com with ESMTP id fb6si1261016icb.68.2015.05.21.06.01.56
        for <linux-mm@kvack.org>;
        Thu, 21 May 2015 06:01:56 -0700 (PDT)
Date: Thu, 21 May 2015 09:01:52 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v6 5/5] trace, ras: move ras_event.h under
 include/trace/events
Message-ID: <20150521090152.182a46ef@gandalf.local.home>
In-Reply-To: <20150521092437.GA3841@nazgul.tnic>
References: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
	<1432179685-11369-6-git-send-email-xiexiuqi@huawei.com>
	<20150521092437.GA3841@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Xie XiuQi <xiexiuqi@huawei.com>, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, gong.chen@linux.intel.com, mingo@redhat.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com, sfr@canb.auug.org.au, rdunlap@infradead.org, jim.epost@gmail.com

On Thu, 21 May 2015 11:24:37 +0200
Borislav Petkov <bp@suse.de> wrote:

> On Thu, May 21, 2015 at 11:41:25AM +0800, Xie XiuQi wrote:
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > 
> > Most of header files for tracepoints are located to include/trace/events or
> > their relevant subdirectories under drivers/. One exception is
> 
> That's simply not true.
> 
> > include/ras/ras_events.h, which looks inconsistent. So let's move it to the
> > default places for such headers.
> 
> No thanks - ras TPs can live just fine in include/ras/.
> 

I agree with Boris, the solution is not to move it. It's not
inconsistent, lots of places use it. Just do a git grep -l TRACE_EVENT
to see.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
