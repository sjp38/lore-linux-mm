Message-ID: <3E5A0F8D.4010202@aitel.hist.no>
Date: Mon, 24 Feb 2003 13:26:53 +0100
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.62-mm3 - no X for me
References: <20030223230023.365782f3.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.5.62-mm3 boots up fine, but won't run X.  Something goes
wrong switching to graphics so my monitor says "no signal"

Using radeonfb:
Switching to the framebuffer console almost works, but
the video mode is messed up so parts of the text appear
all over the screen.  Switching back to X again shows
X in a very messed up video mode, some sort
of resolution mismatch.

Using plain vga console:
Nothing happens on the screen after I get "no signal",
console switching has no effect.  Sync&Reboot via
sysrq works though.

The kernel uses UP, preempt, no module support, devfs configured
but not used.

Hardware:
2.4GHz P4, 512M
01:00.0 VGA compatible controller: ATI Technologies Inc Radeon VE QY
00:01.0 PCI bridge: Silicon Integrated Systems [SiS] 5591/5592 AGP

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
