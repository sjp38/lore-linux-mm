Message-ID: <465219FA.7080305@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de> <46517817.1080208@users.sourceforge.net> <20070521110406.GA14802@vanheusden.com> <Pine.LNX.4.61.0705211420100.4452@yvahk01.tjqt.qr> <20070521124734.GB14802@vanheusden.com> <4651A564.9090509@users.sourceforge.net> <20070521185947.GF14802@vanheusden.com>
In-Reply-To: <20070521185947.GF14802@vanheusden.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Date: Tue, 22 May 2007 00:15:55 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Folkert van Heusden <folkert@vanheusden.com>
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, Andi Kleen <ak@suse.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Folkert van Heusden wrote:
>>>>> What about the following enhancement: I check with sig_fatal if it would
>>>>> kill the process and only then emit a message. So when an application
>>>>> takes care itself of handling it nothing is printed.
>>>>> +	/* emit some logging for unhandled signals
>>>>> +	 */
>>>>> +	if (sig_fatal(t, sig))
>>>> Not unhandled_signal()?
>>> Can we already use that one in send_signal? As the signal needs to be
>>> send first I think before we know if it was handled or not? sig_fatal
>>> checks if the handler is set to default - which is it is not taken care
>>> of.
>> What about ptrace()'d processes? I don't think we should log signals for them...
> 
> Why not?

Maybe sometimes it's useful, maybe not, but I suppose that usually only the
controlling process should care about the critical signals received by the
controlled process. I simply don't think it should be a system issue. For
example I wouldn't like to have a lot of messages in the kernel logs just
because I'm debugging some segfaulting programs with gdb.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
