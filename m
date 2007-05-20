From: Andi Kleen <ak@suse.de>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Date: Sun, 20 May 2007 23:14:57 +0200
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com>
In-Reply-To: <20070520205500.GJ22452@vanheusden.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705202314.57758.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Folkert van Heusden <folkert@vanheusden.com>
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +	switch(sig) {
> +	case SIGQUIT: 
> +	case SIGILL: 
> +	case SIGTRAP:
> +	case SIGABRT: 
> +	case SIGBUS: 
> +	case SIGFPE:
> +	case SIGSEGV: 
> +	case SIGXCPU: 
> +	case SIGXFSZ:
> +	case SIGSYS: 
> +	case SIGSTKFLT:

Unconditional? That's definitely a very bad idea. If anything only unhandled
signals should be printed this way because some programs use them internally. 
But I think your list is far too long anyways.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
