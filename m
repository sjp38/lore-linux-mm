Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 69DDB280245
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 14:31:13 -0400 (EDT)
Received: by iggf3 with SMTP id f3so61386658igg.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 11:31:13 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0100.hostedemail.com. [216.40.44.100])
        by mx.google.com with ESMTP id fm10si6621253igb.25.2015.08.03.11.31.12
        for <linux-mm@kvack.org>;
        Mon, 03 Aug 2015 11:31:12 -0700 (PDT)
Date: Mon, 3 Aug 2015 14:31:09 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC PATCH 09/14] ring_buffer: Initialize completions
 statically in the benchmark
Message-ID: <20150803143109.0b13925b@gandalf.local.home>
In-Reply-To: <1438094371-8326-10-git-send-email-pmladek@suse.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
	<1438094371-8326-10-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 28 Jul 2015 16:39:26 +0200
Petr Mladek <pmladek@suse.com> wrote:

> It looks strange to initialize the completions repeatedly.
> 
> This patch uses static initialization. It simplifies the code
> and even helps to get rid of two memory barriers.

There was a reason I did it this way and did not use static
initializers. But I can't recall why I did that. :-/

I'll have to think about this some more.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
