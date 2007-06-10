Date: Sun, 10 Jun 2007 22:06:54 +0200 (CEST)
From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
In-Reply-To: <20070610195333.GB15616@vanheusden.com>
Message-ID: <Pine.LNX.4.64.0706102200400.23280@twin.jikos.cz>
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr>
 <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de>
 <46517817.1080208@users.sourceforge.net> <20070521110406.GA14802@vanheusden.com>
 <Pine.LNX.4.61.0705211420100.4452@yvahk01.tjqt.qr> <20070521124734.GB14802@vanheusden.com>
 <a781481a0705231100q333a589at6c025eb1292019cd@mail.gmail.com>
 <20070523184535.GE21655@vanheusden.com> <20070610195333.GB15616@vanheusden.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Folkert van Heusden <folkert@vanheusden.com>
Cc: Satyam Sharma <satyam.sharma@gmail.com>, Jan Engelhardt <jengelh@linux01.gwdg.de>, Andrea Righi <righiandr@users.sourceforge.net>, Andi Kleen <ak@suse.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 10 Jun 2007, Folkert van Heusden wrote:

> Signed-of by: Folkert van Heusden <folkert@vanheusden.com

This looks broken BTW.

> +			printk(KERN_INFO "Sig %d sent to %d owned by %d.%d (%s), sent by pid %d, uid %d\n",
> +				sig, t->pid, t->uid, t->gid, t->comm,
> +				info -> _sifields._kill._pid,
> +				info -> _sifields._kill._uid);

Am I the only one whose eyes are hurt by these spaces?

-- 
Jiri Kosina

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
