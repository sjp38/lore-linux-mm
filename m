Subject: Re: 2.6.0-test3-mm3
From: Jonathan Brown <jbrown@emergence.uk.net>
In-Reply-To: <20030819013834.1fa487dc.akpm@osdl.org>
References: <20030819013834.1fa487dc.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1061349342.8327.11.camel@localhost>
Mime-Version: 1.0
Date: Wed, 20 Aug 2003 04:15:43 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

function `mp_find_ioapic'
arch/i386/kernel/mpparse.c:1069: `mp_ioapic_routing' undeclared (first
use in this function)
arch/i386/kernel/mpparse.c:1069: (Each undeclared identifier is reported
only once
arch/i386/kernel/mpparse.c:1069: for each function it appears in.)
arch/i386/kernel/mpparse.c:1071: warning: implicit declaration of
function `io_apic_set_pci_routing'
arch/i386/kernel/mpparse.c: In function `mp_parse_prt':
arch/i386/kernel/mpparse.c:1115: `mp_ioapic_routing' undeclared (first
use in this function)
make[1]: *** [arch/i386/kernel/mpparse.o] Error 1
make: *** [arch/i386/kernel] Error 2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
