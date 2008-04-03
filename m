From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [RFC 01/22] Generic show_mem() implementation
Date: Thu, 03 Apr 2008 16:49:42 +0200
Message-ID: <871w5nouwp.fsf@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
	<1207168839586-git-send-email-hannes@saeurebad.de>
	<20080403075545.GC4125@osiris.boeblingen.de.ibm.com>
	<20080403124820.GA30356@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759772AbYDCOuD@vger.kernel.org>
In-Reply-To: <20080403124820.GA30356@uranus.ravnborg.org> (Sam Ravnborg's
	message of "Thu, 3 Apr 2008 14:48:20 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

Hi,

Sam Ravnborg <sam@ravnborg.org> writes:

>> e.g. we currently have this in arch/s390/Kconfig:
>> 
>> config S390
>>         def_bool y
>>         select HAVE_OPROFILE
>>         select HAVE_KPROBES
>>         select HAVE_KRETPROBES
>> 
>> just add a select HAVE_GENERIC_SHOWMEM or something like that in the arch
>> specific patches.
> Seconded.
> See Documentation/kbuild/kconfig-language.txt for a few more hints
> how to do it.

After more thinking about it, wouldn't it be better to have
HAVE_ARCH_SHOW_MEM in mm/Kconfig and let archs with their own show_mem()
select it?  Because there are far more archs that use the generic
version than those having their own.

	Hannes
