From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.67-mm1
Date: Tue, 8 Apr 2003 12:50:55 -0400
References: <20030408042239.053e1d23.akpm@digeo.com> <200304080917.15648.tomlins@cam.org> <20030408091048.002a2e08.akpm@digeo.com>
In-Reply-To: <20030408091048.002a2e08.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200304081250.55925.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On April 8, 2003 12:10 pm, Andrew Morton wrote:
> Does the below patch help?

Yes.  With it 67-mm1 boots.  I do find the following in dmesg though: 

CPU: AMD-K6(tm) 3D+ Processor stepping 01
Checking 'hlt' instruction... OK.
POSIX conformance testing by UNIFIX
Initializing RT netlink socket
mtrr: v2.0 (20020519)
pty: 256 Unix98 ptys configured
Bad boy: i8042 (at 0xc0320738) called us without a dev_id!
Bad boy: i8042 (at 0xc0320852) called us without a dev_id!
Bad boy: i8042 (at 0xc020a9e8) called us without a dev_id!
serio: i8042 AUX port at 0x60,0x64 irq 12
Bad boy: i8042 (at 0xc020a9e8) called us without a dev_id!
input: AT Set 2 keyboard on isa0060/serio0
serio: i8042 KBD port at 0x60,0x64 irq 1
PCI: PCI BIOS revision 2.10 entry at 0xfb520, last bus=1
PCI: Using configuration type 1
BIO: pool of 256 setup, 14Kb (56 bytes/bio)

Box seems to work fine.  There is nothing plugged onto AUX
as my mouse is USB.  The keyboard is plugged into the other
PS2 port...

Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
