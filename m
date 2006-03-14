Date: Tue, 14 Mar 2006 20:40:25 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH: 003/017](RFC) Memory hotplug for new nodes v.3.(get node id at probe memory)
In-Reply-To: <20060310154600.CA73.Y-GOTO@jp.fujitsu.com>
References: <20060309040031.2be49ec2.akpm@osdl.org> <20060310154600.CA73.Y-GOTO@jp.fujitsu.com>
Message-Id: <20060314201603.9159.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jschopp@austin.ibm.com, haveblue@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> > >
> > > When CONFIG_NUMA && CONFIG_ARCH_MEMORY_PROBE, nid should be defined
> > >  before calling add_memory_node(nid, start, size).
> > > 
> > >  Each arch , which supports CONFIG_NUMA && ARCH_MEMORY_PROBE, should
> > >  define arch_nid_probe(paddr);
> > > 
> > >  Powerpc has nice function. X86_64 has not.....
> > 
> > This patch uses an odd mixture of __devinit and <nothing-at-all> in
> > arch/x86_64/mm/init.c.  I guess it should be using __meminit
> > throughout.
> 
>   Oh... I made mistake. I'll fix them.

Hmmm. I'm confusing again about this. :-(

Dave-san, Joel-san.

Why does Powerpc use __devinit for add_memory()?
Usually, add_memory() is never called at boottime.
So, I suppose __meminit nor __devinit is not needed at all around here.

But, does it have a plan that add_memory() is called only boottime on 
Powerpc?


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
