Date: Tue, 12 Jun 2007 10:50:33 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: mm: memory/cpu hotplug section mismatch.
In-Reply-To: <20070611184046.GA6458@uranus.ravnborg.org>
References: <20070611154428.GA27644@linux-sh.org> <20070611184046.GA6458@uranus.ravnborg.org>
Message-Id: <20070612102236.E8BA.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Paul Mundt <lethal@linux-sh.org>, Randy Dunlap <randy.dunlap@oracle.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > 
> > If CONFIG_MEMORY_HOTPLUG=n __meminit == __init, and if
> > CONFIG_HOTPLUG_CPU=n __cpuinit == __init. However, with one set and the
> > other disabled, you end up with a reference between __init and a regular
> > non-init function.
> 
> My plan is to define dedicated sections for both __devinit and __meminit.
> Then we can apply the checks no matter the definition of CONFIG_HOTPLUG*

I prefer defining "__nodeinit" for __cpuinit and __meminit case to
__devinit.   __devinit is used many devices like I/O, and it is
useful for many desktop users. But, cpu/memory hotpluggable box
is very rare. And it should be in init section for many people.

This kind of issue is caused by initialization of pgdat/zone.
I think __nodeinit is enough and desirable.

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
