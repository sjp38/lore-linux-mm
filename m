Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id ADB6A6B0044
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 07:07:17 -0400 (EDT)
Message-ID: <1343214366.2534.7.camel@bandura>
Subject: Re: [PATCH 01/24] uprobes, mm, x86: Add the ability to install and
 remove uprobes breakpoints
From: Anton Arapov <anton@redhat.com>
Date: Wed, 25 Jul 2012 13:06:06 +0200
In-Reply-To: <20120725084242.887ffaaf5a343ba8893b02c1@canb.auug.org.au>
References: <cover.1343163918.git.Torsten.Polle@gmx.de>
	 <7c692867a3b75d6c2954b09339dd1b851998c997.1343163918.git.Torsten.Polle@gmx.de>
	 <20120725084242.887ffaaf5a343ba8893b02c1@canb.auug.org.au>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Torsten Polle <Torsten.Polle@gmx.de>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, tpolle@de.adit-jv.com, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Denys Vlasenko <vda.linux@googlemail.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>

Hello All,
  /apologize for the top-posting/

  I guess Torsten become a victim of 'git send' syndrome or something
similar, IOW these patches were sent by accident. Uprobes was committed
to Linus' tree a while back already.
  
Thanks,
Anton.

On Wed, 2012-07-25 at 08:42 +1000, Stephen Rothwell wrote:
> Hi Torsten,
> 
> Just a couple of quick suggestions:
> 
> On Tue, 24 Jul 2012 23:12:45 +0200 Torsten Polle <Torsten.Polle@gmx.de> wrote:
> >
> 
> Firstly, don't attach patches, put them inline in you email - it makes
> it easier for reviewers to comment on them.
> 
> > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > index c9866b0..1f5c307 100644
> > --- a/arch/x86/Kconfig
> > +++ b/arch/x86/Kconfig
> > @@ -243,6 +243,9 @@ config ARCH_CPU_PROBE_RELEASE
> >  	def_bool y
> >  	depends on HOTPLUG_CPU
> >  
> > +config ARCH_SUPPORTS_UPROBES
> > +	def_bool y
> > +
> 
> You should put this in arch/Kconfig (as just a bool- no default) and
> then select it in the x86 Kconfig.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
