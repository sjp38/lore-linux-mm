Message-ID: <464FC6AA.2060805@cosmosbay.com>
Date: Sun, 20 May 2007 05:55:22 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705180825280.3231@yvahk01.tjqt.qr> <200705181347.14256.ak@suse.de> <Pine.LNX.4.61.0705190946430.9015@yvahk01.tjqt.qr> <20070520001418.GJ14578@vanheusden.com>
In-Reply-To: <20070520001418.GJ14578@vanheusden.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Folkert van Heusden <folkert@vanheusden.com>
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, Andi Kleen <ak@suse.de>, Rik van Riel <riel@redhat.com>, righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Folkert van Heusden a ecrit :
>>>> I do not see such on i386, so why for x86_64?
>>> So that you know that one of your programs crashed. That's a feature.
>> This feature could be handy for i386 too.
> 
> Since 2.6.18.2 I use this patch. With 2.6.21.1 it still applies altough
> with a small offsets. Works like a charm.
> 
> 
> Signed-off by: Folkert van Heusden <folkert@vanheusden.com>
> 
> --- linux-2.6.18.2/kernel/signal.c      2006-11-04 02:33:58.000000000 +0100
> +++ linux-2.6.18.2.new/kernel/signal.c  2006-11-17 15:59:13.000000000 +0100
> @@ -706,6 +706,15 @@
>         struct sigqueue * q = NULL;
>         int ret = 0;
> 
> +       if (sig == SIGQUIT || sig == SIGILL  || sig == SIGTRAP ||
> +           sig == SIGABRT || sig == SIGBUS  || sig == SIGFPE  ||
> +           sig == SIGSEGV || sig == SIGXCPU || sig == SIGXFSZ ||
> +           sig == SIGSYS  || sig == SIGSTKFLT)
> +       {
> +               printk(KERN_WARNING "Sig %d send to %d owned by %d.%d (%s)\n",
> +                       sig, t -> pid, t -> uid, t -> gid, t -> comm);
> +       }
> +

Please check line 219 of Documentation/CodingStyle, Section 3.1: Spaces

	and no space around the '.' and "->" structure member operators.

Thank you

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
