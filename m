Date: Fri, 30 Aug 2002 01:31:00 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: statm_pgd_range() sucks!
Message-ID: <20020830083100.GQ18114@holomorphy.com>
References: <20020830015814.GN18114@holomorphy.com> <20020830082456.GC10656@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020830082456.GC10656@krispykreme>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@zip.com.au, riel@surriel.com
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>> Okay, I have *had it* with statm_pgd_range()!

On Fri, Aug 30, 2002 at 06:24:56PM +1000, Anton Blanchard wrote:
> On a related note, it would be nice if procps would not parse things it
> doesnt need:
> strace ps 2>&1 | grep open | grep '/proc'
> open("/proc/12467/stat", O_RDONLY)      = 7
> open("/proc/12467/statm", O_RDONLY)     = 7
> open("/proc/12467/status", O_RDONLY)    = 7
> open("/proc/12467/cmdline", O_RDONLY)   = 7
> open("/proc/12467/environ", O_RDONLY)   = 7
> It always opens statm even when its not required.
> Anton

Userspace is FITH, it only needs to do it for BSD-style stuff reporting
RSS/vsz. vsz is wrong anyway if it doesn't open /proc/$PID/maps.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
