Subject: Re: 2.6.0-test3-mm3
From: Flameeyes <daps_mls@libero.it>
In-Reply-To: <20030819013834.1fa487dc.akpm@osdl.org>
References: <20030819013834.1fa487dc.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1061287775.5995.7.camel@defiant.flameeyes>
Mime-Version: 1.0
Date: Tue, 19 Aug 2003 12:09:36 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-08-19 at 10:38, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test3/2.6.0-test3-mm3/

there's a problem with make xconfig:

defiant:/usr/src/linux-2.6.0-test3-mm3# make xconfig
  CC      scripts/empty.o
  MKELF   scripts/elfconfig.h
  HOSTCC  scripts/file2alias.o
  HOSTCC  scripts/modpost.o
  HOSTLD  scripts/modpost
make[1]: *** No rule to make target `scripts/kconfig/qconf.c', needed by
`scripts/kconfig/qconf'.  Stop.
make: *** [xconfig] Error 2


also, the ACPI entries seems vanished in the .config, and the menu is
not accessible.
With the old 2.6.0-test3-mm2 no problem at all.

-- 
Flameeyes <dgp85@users.sf.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
