Date: Fri, 13 Jul 2001 23:09:54 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] VM statistics code
In-Reply-To: <3B4FBC7E.D8694436@uow.edu.au>
Message-ID: <Pine.LNX.4.21.0107132308040.4111-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 14 Jul 2001, Andrew Morton wrote:

> Marcelo Tosatti wrote:
> > 
> > Hi Linus,
> > 
> > The following patch adds detailed VM statistics (reported via /proc/stats)
> > which is tunable on/off by the CONFIG_VM_STATS option.
> 
> We need this, bad.  Two suggested changes:
> 
> >
> > +#define VM_STAT_INC_PTEUNMAP(zone) zone->stat.vm_pteunmap++;
> 
> All these macros are a waste of space :)
> 
> Much better to have:
> 
> #define VM_STAT_ZONE(zone, op)	zone->stat.op
> 
> Then, at the call site:
> 
> 	VM_STAT_ZONE(some_zone, vm_pteunmap++);
> 
> Or, if you prefer,
> 
> #define VM_STAT_ZONE_INC(zone, field)	zone->field++
> 
> That way, you don't have to add a new macro each time
> you add a new field.

You're right. Will do that.

> Also, a sysrq key which dumps the stats out, please - when
> your box has wedged there ain't no way you'll be running
> vmstat.

Agreed. 

Thanks for your comments. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
