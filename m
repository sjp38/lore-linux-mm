Subject: Re: 2.6.0-test3-mm3
From: Flameeyes <daps_mls@libero.it>
In-Reply-To: <20030819032350.55339908.akpm@osdl.org>
References: <20030819013834.1fa487dc.akpm@osdl.org>
	 <1061287775.5995.7.camel@defiant.flameeyes>
	 <20030819032350.55339908.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1061289265.5993.11.camel@defiant.flameeyes>
Mime-Version: 1.0
Date: Tue, 19 Aug 2003 12:34:26 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-08-19 at 12:23, Andrew Morton wrote:
> You'll need to enable CONFIG_X86_LOCAL_APIC to work around this.
I can't, if I enable it, my system freezes at boot time (before activate
the framebuffer), disabling framebuffer to see the output, the last
message is "Calibrating APIC timer", also if I pass noapic to the kernel
boot params, the system freezes at the same point.

-- 
Flameeyes <dgp85@users.sf.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
