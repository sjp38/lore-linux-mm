Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E2B996B012C
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 13:22:11 -0400 (EDT)
Subject: Re: [PATCH 2/2] mm: Document handle_mm_fault()
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <BANLkTikgxKNx1eyR1m6NpVA5Ykfduzq-Mw@mail.gmail.com>
References: <20110628164750.281686775@goodmis.org>
	 <20110628165303.010143380@goodmis.org>
	 <BANLkTikgxKNx1eyR1m6NpVA5Ykfduzq-Mw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 28 Jun 2011 13:22:09 -0400
Message-ID: <1309281729.26417.14.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Gleb Natapov <gleb@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>

On Tue, 2011-06-28 at 10:02 -0700, Linus Torvalds wrote:
> On Tue, Jun 28, 2011 at 9:47 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> > + * Note: if @flags has FAULT_FLAG_ALLOW_RETRY set then the mmap_sem
> > + *       may be released if it failed to arquire the page_lock. If the
> > + *       mmap_sem is released then it will return VM_FAULT_RETRY set.
> > + *       This is to keep the time mmap_sem is held when the page_lock
> > + *       is taken for IO.
> 
> So I know what that flag does, but I knew it without the comment.
> 
> WITH the comment, I'm just confused. "This is to keep the time
> mmap_sem is held when the page_lock is taken for IO."
> 
> Sounds like a google translation from swahili. "keep the time" what?

"When people ask me what language is my mother tongue, I simply reply C"

Google translate from C -> english is worse than swahily -> english :p

> 
> Maybe "keep" -> "minimize"? Or just "This is to avoid holding mmap_sem
> while waiting for IO"

OK, that sounds better. Thanks.

I'll go to cut a v2, but I'll wait a day or so for others to comment.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
