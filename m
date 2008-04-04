From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC 01/22] Generic show_mem() implementation
Date: Sat, 05 Apr 2008 01:10:32 +0200
Message-ID: <87d4p5kyhj.fsf@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
	<1207168839586-git-send-email-hannes@saeurebad.de>
	<20080403075545.GC4125@osiris.boeblingen.de.ibm.com>
	<20080403124820.GA30356@uranus.ravnborg.org>
	<871w5nouwp.fsf@saeurebad.de>
	<20080403181202.GA32319@uranus.ravnborg.org>
	<87prt6muux.fsf@saeurebad.de>
	<20080404213540.GA15535@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754178AbYDDXLA@vger.kernel.org>
In-Reply-To: <20080404213540.GA15535@uranus.ravnborg.org> (Sam Ravnborg's
	message of "Fri, 4 Apr 2008 23:35:40 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

Hi Sam,

Sam Ravnborg <sam@ravnborg.org> writes:

>> >> After more thinking about it, wouldn't it be better to have
>> >> HAVE_ARCH_SHOW_MEM in mm/Kconfig and let archs with their own show_mem()
>> >> select it?  Because there are far more archs that use the generic
>> >> version than those having their own.
>> >
>> > Positive logic is almost always simpler to grasp.
>> > And the usual way to do this is to let arch's select what they
>> > use.
>> > We do not want to have a situation where in most cases we select
>> > a generic version but in some oddball case we select to have
>> > a local version.
>> 
>> I can not follow you.  Of course the arch selects what they use.  But
>> they should not _all_ have to be flagged with an extra select.  So what
>> default-value are you arguing for?
> The normal pattern is to let arch select the generic implmentation they
> use.
> Just because the majority does use the generic version should not
> make us start to use the inverse logic as in your case.
>
> So I want all archs that uses the generic show_mem() to
> do an explicit:
>
> config MYARCH
> 	select HAVE_GENERIC_SHOWMEM
>
> 	Sam

What is the rationale behind this?  It is not a function the arch should
select at all because it is VM code.  The remaining arch-specific
versions are meant to be removed too.

It would be like forcing all architectures to select HAVE_GENERIC_PRINTK
just because one architecture oopses on printk() and needs to replace it
with its own version.

	Hannes
