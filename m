Message-ID: <46517817.1080208@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de>
In-Reply-To: <200705202314.57758.ak@suse.de>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Date: Mon, 21 May 2007 12:45:06 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Folkert van Heusden <folkert@vanheusden.com>
Cc: Andi Kleen <ak@suse.de>, Jan Engelhardt <jengelh@linux01.gwdg.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>> +	switch(sig) {
>> +	case SIGQUIT: 
>> +	case SIGILL: 
>> +	case SIGTRAP:
>> +	case SIGABRT: 
>> +	case SIGBUS: 
>> +	case SIGFPE:
>> +	case SIGSEGV: 
>> +	case SIGXCPU: 
>> +	case SIGXFSZ:
>> +	case SIGSYS: 
>> +	case SIGSTKFLT:
> 
> Unconditional? That's definitely a very bad idea. If anything only unhandled
> signals should be printed this way because some programs use them internally. 
> But I think your list is far too long anyways.
> 
> -Andi
> 

Maybe you could use somthing similar to unhandled_signal() in
arch/x86_64/mm/fault.c, but I agree that the list seems a bit too long...

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
