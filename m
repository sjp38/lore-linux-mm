Subject: Re: 2.5.69-mm1
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030504231650.75881288.akpm@digeo.com>
References: <20030504231650.75881288.akpm@digeo.com>
Content-Type: text/plain
Message-Id: <1052231590.2166.141.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 06 May 2003 08:33:10 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2003-05-05 at 00:16, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm1/
> 
> Various random fixups, cleanps and speedups.  Mainly a resync to 2.5.69.
> 
I have one machine for testing which is running X, and a kexec reboot
glitches the video system when initiated from runlevel 5.  Kexec works fine
from runlevel 3.

I was not able to test this until now, due to the "crash on leaving X"
bug which has been fixed in 2.5.69.

The symptoms are a blank screen for the 35 seconds that it takes this
box to do a kexec boot following do-kexec.sh /boot/vmlinuz-2.5.69-mm1
Then, if I had "id:3:initdefault:" in /etc/inittab, I just get a blank screen
at the console, but I can ssh into the box since it does come up fine otherwise.
If I had runlevel 5 instead in the above, then X starts OK (after a blank screen
startup) and all is well.

[steven@spc1 steven]$ /sbin/lspci
00:00.0 Host bridge: Intel Corp. 82810E DC-133 GMCH [Graphics Memory Controller Hub] (rev 03)
00:01.0 VGA compatible controller: Intel Corp. 82810E DC-133 CGC [Chipset Graphics Controller] (rev 03)
00:1e.0 PCI bridge: Intel Corp. 82801AA PCI Bridge (rev 02)
00:1f.0 ISA bridge: Intel Corp. 82801AA ISA Bridge (LPC) (rev 02)
00:1f.1 IDE interface: Intel Corp. 82801AA IDE (rev 02)
00:1f.2 USB Controller: Intel Corp. 82801AA USB (rev 02)
00:1f.3 SMBus: Intel Corp. 82801AA SMBus (rev 02)
00:1f.5 Multimedia audio controller: Intel Corp. 82801AA AC'97 Audio (rev 02)
01:0c.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 78)

snippet from dmesg:

Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected an Intel i810 E Chipset.
agpgart: Maximum main memory to use for agp memory: 202M
agpgart: detected 4MB dedicated video ram.
agpgart: AGP aperture is 64M @ 0xf8000000
[drm] Initialized i810 1.2.1 20020211 on minor 0

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
