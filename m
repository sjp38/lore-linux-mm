Date: Sun, 13 Oct 2002 14:03:01 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.42-mm2 hangs system
Message-ID: <20021013210301.GE2032@holomorphy.com>
References: <20021013160451.GA25494@hswn.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021013160451.GA25494@hswn.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Henrik St?rner <henrik@hswn.dk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Oct 13, 2002 at 06:04:51PM +0200, Henrik St?rner wrote:
> I gave 2.5.42-mm2 a test run yesterday, and it hung the box solid
> while doing a kernel compile. The compile stopped dead in the middle
> of a file, and there was no response when trying to access another
> console (no X running). Alt-sysrq worked, so it wasn't completely dead
> - sync/umount/reboot worked.
> Nothing in the logs - no oops or other kernel messages.
> Rebooted and repeated the experiment with the same result,
> so it appears to be reproducible.
> Stock 2.5.42 has worked OK for a day now, including kernel
> compiles - the system has performed flawlessly for a 
> couple of years as my normal workstation.
> PII processor, 384 MB RAM, SCSI disk (ncr53c8xx driver),
> Intel eepro/100 network adapter. Kernel config at
> http://www.hswn.dk/config-2.5.42-mm2

Please reproduce and pass on the output from sysrq-t.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
