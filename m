Date: Tue, 19 Aug 2003 03:23:50 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test3-mm3
Message-Id: <20030819032350.55339908.akpm@osdl.org>
In-Reply-To: <1061287775.5995.7.camel@defiant.flameeyes>
References: <20030819013834.1fa487dc.akpm@osdl.org>
	<1061287775.5995.7.camel@defiant.flameeyes>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Flameeyes <daps_mls@libero.it>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sam Ravnborg <sam@ravnborg.org>
List-ID: <linux-mm.kvack.org>

Flameeyes <daps_mls@libero.it> wrote:
>
> On Tue, 2003-08-19 at 10:38, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test3/2.6.0-test3-mm3/
> 
> there's a problem with make xconfig:
> 
> defiant:/usr/src/linux-2.6.0-test3-mm3# make xconfig
>   CC      scripts/empty.o
>   MKELF   scripts/elfconfig.h
>   HOSTCC  scripts/file2alias.o
>   HOSTCC  scripts/modpost.o
>   HOSTLD  scripts/modpost
> make[1]: *** No rule to make target `scripts/kconfig/qconf.c', needed by
> `scripts/kconfig/qconf'.  Stop.
> make: *** [xconfig] Error 2

umm, Sam?

> 
> also, the ACPI entries seems vanished in the .config, and the menu is
> not accessible.
> With the old 2.6.0-test3-mm2 no problem at all.

You'll need to enable CONFIG_X86_LOCAL_APIC to work around this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
