Message-ID: <20051026050627.69339.qmail@web35602.mail.mud.yahoo.com>
Date: Tue, 25 Oct 2005 22:06:27 -0700 (PDT)
From: salve vandana <vandanasalve@yahoo.com>
Subject: __alloc_pages: 0-order allocation failed (gfp=0x1d2/0)
In-Reply-To: <20051026024831.GB17191@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

I am getting this VM error on 2.4.28kernel(RAM-768MB,
No Swap and the root file system,whose size is around
300MB is loaded as initrd).
After the error the processes are getting killed and
system is rebooted. I am not understanding why the MM
is trying is allocate pages from HIGH Memory
(gfp=0x1d2/0) when I dont have High memory and the
kernel is also not enabled to support High memory. I
have put the printk's to see how kswapd is woken up to
free unused pages because I dont want to run out of
memory.

Here is log:

try_to_free_pages_zone
try_to_free_pages_zone
try_to_free_pages_zone
__alloc_pages: 0-order allocation failed (gfp=0x1d2/0)
VM: killing process cp_test
Received SIGCHLDtry_to_free_pages_zone
cp_test exited (PID = 213).Invalid TFTP URL for
exporting crash-dumps...
__alloc_pages: 0-order allocation failed (gfp=0x1f0/0)
ry_to_free_pages_zone
try_to_free_pages_zone
try_to_free_pages_zone

Thanks,
Vandana




		
__________________________________ 
Yahoo! FareChase: Search multiple travel sites in one click.
http://farechase.yahoo.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
