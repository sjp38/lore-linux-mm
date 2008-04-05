From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [RFC 01/22] Generic show_mem() implementation
Date: Sat, 5 Apr 2008 10:04:03 +0100
Message-ID: <20080405090403.GA24316@linux-mips.org>
References: <12071688283927-git-send-email-hannes@saeurebad.de> <1207168839586-git-send-email-hannes@saeurebad.de> <20080403075545.GC4125@osiris.boeblingen.de.ibm.com> <20080403124820.GA30356@uranus.ravnborg.org> <871w5nouwp.fsf@saeurebad.de> <20080403181202.GA32319@uranus.ravnborg.org> <87prt6muux.fsf@saeurebad.de> <20080404213540.GA15535@uranus.ravnborg.org> <87d4p5kyhj.fsf@saeurebad.de> <20080405075108.GA6730@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751978AbYDEJVg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080405075108.GA6730@osiris.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Johannes Weiner <hannes@saeurebad.de>, Sam Ravnborg <sam@ravnborg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sourceforge.net, takata@linux-m32r.org, geert@linux-m68k.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

On Sat, Apr 05, 2008 at 09:51:08AM +0200, Heiko Carstens wrote:

> But you can solve this problem with no ifdefs and config options at all,
> since you may as well just use __attribute__((weak)) for the generic
> implementation.

Which may result in the version of the function getting linked in but
staying unreferenced.

  Ralf
