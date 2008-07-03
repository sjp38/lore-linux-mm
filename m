From: Grant Coady <grant_lkml@dodo.com.au>
Subject: Re: 2.6.26-rc8-mm1--No e100 :( logs say missing firmware
Date: Fri, 04 Jul 2008 09:42:54 +1000
Reply-To: Grant Coady <gcoady.lk@gmail.com>
Message-ID: <6toq6493rbba4n4s8l2csvobo13673tgu5@4ax.com>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
In-Reply-To: <20080703020236.adaa51fa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2008 02:02:36 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:

>ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc8/2.6.26-rc8-mm1/

Hi, it booted up on a Core2Duo box but failed to connect via e100 NIC 
to localnet.

/var/log/messages:

Jul  4 09:14:13 pooh kernel: firmware: requesting e100/d102e_ucode.bin
Jul  4 09:14:13 pooh firmware.sh[1666]: Cannot find  firmware file 'e100/d102e_ucode.bin'

/var/log/syslog:

Jul  4 09:14:13 pooh kernel: e100: eth0: e100_request_firmware: Failed to load firmware "e100/d1
02e_ucode.bin": -2
Jul  4 09:14:13 pooh kernel: e100: eth0: e100_request_firmware: Failed to load firmware "e100/d1
02e_ucode.bin": -2
Jul  4 09:17:17 pooh kernel: e100: eth0: e100_request_firmware: Failed to load firmware "e100/d1
02e_ucode.bin": -2
Jul  4 09:17:30 pooh last message repeated 3 times

So where did the firmware go? -- I been using these e100 NICs for years, 
2.4 & 2.6 kernels, never seen this kind of failure...


Duped mesg with typo corrected so searching Subject line works.

Thanks,
Grant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
