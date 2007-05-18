Date: Fri, 18 May 2007 08:28:13 +0200 (MEST)
From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
In-Reply-To: <464C9D82.60105@redhat.com>
Message-ID: <Pine.LNX.4.61.0705180825280.3231@yvahk01.tjqt.qr>
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On May 17 2007 14:22, Rik van Riel wrote:
> Andrea Righi wrote:
>> I'm looking for a way to keep track of the processes that fail to allocate
>> new
>> virtual memory. What do you think about the following approach (untested)?
>
> Looks like an easy way for users to spam syslogd over and
> over and over again.
>
> At the very least, shouldn't this be dependant on print_fatal_signals?

Speaking of signals, everytime I get a segfault (or force one with a test
program) on x86_64, the kernel prints to dmesg:

fail[22278]: segfault at 0000000000000000 rip 00000000004004b8 rsp
00007ffff7ecda50 error 6

I do not see such on i386, so why for x86_64?


	Jan
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
