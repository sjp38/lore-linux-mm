Date: Tue, 19 Aug 2003 20:23:29 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test3-mm3
Message-Id: <20030819202329.24e938ac.akpm@osdl.org>
In-Reply-To: <1061349342.8327.11.camel@localhost>
References: <20030819013834.1fa487dc.akpm@osdl.org>
	<1061349342.8327.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Brown <jbrown@emergence.uk.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@intel.com
List-ID: <linux-mm.kvack.org>

Jonathan Brown <jbrown@emergence.uk.net> wrote:
>
>   CC      arch/i386/kernel/mpparse.o
> arch/i386/kernel/mpparse.c: In function `mp_config_ioapic_for_sci':
> arch/i386/kernel/mpparse.c:1067: warning: implicit declaration of
> function `mp_find_ioapic'
> arch/i386/kernel/mpparse.c:1069: `mp_ioapic_routing' undeclared (first
> use in this function)
> arch/i386/kernel/mpparse.c:1069: (Each undeclared identifier is reported
> only once
> arch/i386/kernel/mpparse.c:1069: for each function it appears in.)
> arch/i386/kernel/mpparse.c:1071: warning: implicit declaration of
> function `io_apic_set_pci_routing'
> arch/i386/kernel/mpparse.c: In function `mp_parse_prt':
> arch/i386/kernel/mpparse.c:1115: `mp_ioapic_routing' undeclared (first
> use in this function)
> make[1]: *** [arch/i386/kernel/mpparse.o] Error 1
> make: *** [arch/i386/kernel] Error 2
> 

Please send your .config to linux-acpi@intel.com and the fine folks
there will fix it up, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
