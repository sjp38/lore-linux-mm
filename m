Message-ID: <3B4FBC7E.D8694436@uow.edu.au>
Date: Sat, 14 Jul 2001 13:29:02 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: [PATCH] VM statistics code
References: <Pine.LNX.4.21.0107131856470.3716-100000@freak.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> 
> Hi Linus,
> 
> The following patch adds detailed VM statistics (reported via /proc/stats)
> which is tunable on/off by the CONFIG_VM_STATS option.

We need this, bad.  Two suggested changes:

>
> +#define VM_STAT_INC_PTEUNMAP(zone) zone->stat.vm_pteunmap++;

All these macros are a waste of space :)

Much better to have:

#define VM_STAT_ZONE(zone, op)	zone->stat.op

Then, at the call site:

	VM_STAT_ZONE(some_zone, vm_pteunmap++);

Or, if you prefer,

#define VM_STAT_ZONE_INC(zone, field)	zone->field++

That way, you don't have to add a new macro each time
you add a new field.



Also, a sysrq key which dumps the stats out, please - when
your box has wedged there ain't no way you'll be running
vmstat.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
