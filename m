Date: Tue, 19 Aug 2003 06:51:27 -0400 (EDT)
From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: Re: 2.6.0-test3-mm3
In-Reply-To: <1061289265.5993.11.camel@defiant.flameeyes>
Message-ID: <Pine.LNX.4.53.0308190651010.25386@montezuma.mastecende.com>
References: <20030819013834.1fa487dc.akpm@osdl.org>  <1061287775.5995.7.camel@defiant.flameeyes>
  <20030819032350.55339908.akpm@osdl.org> <1061289265.5993.11.camel@defiant.flameeyes>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Flameeyes <daps_mls@libero.it>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Aug 2003, Flameeyes wrote:

> On Tue, 2003-08-19 at 12:23, Andrew Morton wrote:
> > You'll need to enable CONFIG_X86_LOCAL_APIC to work around this.
> I can't, if I enable it, my system freezes at boot time (before activate
> the framebuffer), disabling framebuffer to see the output, the last
> message is "Calibrating APIC timer", also if I pass noapic to the kernel
> boot params, the system freezes at the same point.

Boot with nolapic
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
