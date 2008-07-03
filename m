Date: Thu, 03 Jul 2008 20:59:36 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
In-Reply-To: <20080703020236.adaa51fa.akpm@linux-foundation.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
Message-Id: <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mchan@broadcom.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Michael,

my server output following error message on 2.6.26-rc8-mm1.
Is this a bug?

------------------------------------------------------------------
tg3.c:v3.93 (May 22, 2008)
GSI 72 (level, low) -> CPU 0 (0x0001) vector 51
tg3 0000:06:01.0: PCI INT A -> GSI 72 (level, low) -> IRQ 51
firmware: requesting tigon/tg3_tso.bin
tg3: Failed to load firmware "tigon/tg3_tso.bin"
tg3 0000:06:01.0: PCI INT A disabled
GSI 72 (level, low) -> CPU 0 (0x0001) vector 51 unregistered
tg3: probe of 0000:06:01.0 failed with error -2
GSI 73 (level, low) -> CPU 0 (0x0001) vector 51
tg3 0000:06:01.1: PCI INT B -> GSI 73 (level, low) -> IRQ 52
firmware: requesting tigon/tg3_tso.bin



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
