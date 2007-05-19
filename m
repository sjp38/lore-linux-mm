Message-ID: <464EC4E4.5030401@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705180825280.3231@yvahk01.tjqt.qr> <200705181347.14256.ak@suse.de> <Pine.LNX.4.61.0705190946430.9015@yvahk01.tjqt.qr>
In-Reply-To: <Pine.LNX.4.61.0705190946430.9015@yvahk01.tjqt.qr>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Date: Sat, 19 May 2007 11:35:39 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Cc: Andi Kleen <ak@suse.de>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jan Engelhardt wrote:
> On May 18 2007 13:47, Andi Kleen wrote:
>>> I do not see such on i386, so why for x86_64?
>> So that you know that one of your programs crashed. That's a feature.
> 
> This feature could be handy for i386 too.
> 

What about your /proc/sys/kernel/print-fatal-signals? it must be set to 1 to
enable that feature.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
