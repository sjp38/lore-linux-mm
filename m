Message-ID: <464D5AA4.8080900@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: Re: [RFC] log out-of-virtual-memory events
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com>
In-Reply-To: <464C9D82.60105@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Date: Fri, 18 May 2007 09:50:03 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Andrea Righi wrote:
>> I'm looking for a way to keep track of the processes that fail to
>> allocate new
>> virtual memory. What do you think about the following approach
>> (untested)?
>
> Looks like an easy way for users to spam syslogd over and
> over and over again.
>
> At the very least, shouldn't this be dependant on print_fatal_signals?
>

Anyway, with print-fatal-signals enabled a user could spam syslogd too, simply
with a (char *)0 = 0 program, but we could always identify the spam attempts
logging the process uid...

In any case, I agree, it should depend on that patch...

What about adding a simple msleep_interruptible(SOME_MSECS) at the end of
log_vm_enomem() or, at least, a might_sleep() to limit the potential spam/second
rate?

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
