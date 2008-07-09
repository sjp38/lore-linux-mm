Date: Wed, 9 Jul 2008 15:05:12 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: 2.6.26-rc8-mm1 - Missing AC97 power save Kconfig?
Message-Id: <20080709150512.3b3bfdcf.randy.dunlap@oracle.com>
In-Reply-To: <48752EB2.8050406@acm.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	<48752EB2.8050406@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zan Lynx <zlynx@acm.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 09 Jul 2008 15:33:38 -0600 Zan Lynx wrote:

> Andrew Morton wrote:
> > 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc8/2.6.26-rc8-mm1/
> > 
> > - Seems to work on my x86 test boxes.  It does emit a
> >   sleeping-while-atomic warning during exit from an application which
> >   holds mlocks.  Known problem.
> > 
> > - It's dead as a doornail on the powerpc Mac g5.  I'll bisect it later.
> [cut]
> 
> I don't know if this is well known, or why no one else noticed if it
> isn't, but the AC97 power-save Kconfig option CONFIG_SND_AC97_POWER_SAVE
> isn't in any of the Kconfig files.

Did you search for just /SND_AC97_POWER_SAVE/ ?  (no CONFIG_)

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
