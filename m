Date: Fri, 4 Jul 2003 01:53:00 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1 fails to boot due to APIC trouble, 2.5.73mm3 works.
Message-ID: <20030704085300.GY26348@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <3F054109.2050100@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3F054109.2050100@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2003 at 10:55:37AM +0200, Helge Hafting wrote:
> 2.5.74-mm1 dies very early during bootup due to some APIC trouble:
> (written down by hand)
> Posix conformance testing by UNIFIX
> enabled Extint on cpu #0
> ESR before enabling vector 00000000
> ESR after enabling vector 00000000
> Enabling IP-APIC IRQs
> BIOS bug, IO-APIC #0 ID2 is already used!...
> kernel panic: Max APIC ID exceeded!

Okay, fixing.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
