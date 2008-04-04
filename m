From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC 01/22] Generic show_mem() implementation
Date: Fri, 4 Apr 2008 23:35:40 +0200
Message-ID: <20080404213540.GA15535@uranus.ravnborg.org>
References: <12071688283927-git-send-email-hannes@saeurebad.de> <1207168839586-git-send-email-hannes@saeurebad.de> <20080403075545.GC4125@osiris.boeblingen.de.ibm.com> <20080403124820.GA30356@uranus.ravnborg.org> <871w5nouwp.fsf@saeurebad.de> <20080403181202.GA32319@uranus.ravnborg.org> <87prt6muux.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753230AbYDDVf3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87prt6muux.fsf@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

On Fri, Apr 04, 2008 at 12:33:42AM +0200, Johannes Weiner wrote:
> Hi,
> 
> Sam Ravnborg <sam@ravnborg.org> writes:
> 
> > On Thu, Apr 03, 2008 at 04:49:42PM +0200, Johannes Weiner wrote:
> >> Hi,
> >> 
> >> Sam Ravnborg <sam@ravnborg.org> writes:
> >> 
> >> >> e.g. we currently have this in arch/s390/Kconfig:
> >> >> 
> >> >> config S390
> >> >>         def_bool y
> >> >>         select HAVE_OPROFILE
> >> >>         select HAVE_KPROBES
> >> >>         select HAVE_KRETPROBES
> >> >> 
> >> >> just add a select HAVE_GENERIC_SHOWMEM or something like that in the arch
> >> >> specific patches.
> >> > Seconded.
> >> > See Documentation/kbuild/kconfig-language.txt for a few more hints
> >> > how to do it.
> >> 
> >> After more thinking about it, wouldn't it be better to have
> >> HAVE_ARCH_SHOW_MEM in mm/Kconfig and let archs with their own show_mem()
> >> select it?  Because there are far more archs that use the generic
> >> version than those having their own.
> >
> > Positive logic is almost always simpler to grasp.
> > And the usual way to do this is to let arch's select what they
> > use.
> > We do not want to have a situation where in most cases we select
> > a generic version but in some oddball case we select to have
> > a local version.
> 
> I can not follow you.  Of course the arch selects what they use.  But
> they should not _all_ have to be flagged with an extra select.  So what
> default-value are you arguing for?
The normal pattern is to let arch select the generic implmentation they
use.
Just because the majority does use the generic version should not
make us start to use the inverse logic as in your case.

So I want all archs that uses the generic show_mem() to
do an explicit:

config MYARCH
	select HAVE_GENERIC_SHOWMEM

	Sam
