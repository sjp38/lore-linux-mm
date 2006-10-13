From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061013143516.15438.8802.sendpatchset@linux.site>
Subject: [rfc] buffered write deadlock fix
Date: Fri, 13 Oct 2006 18:43:52 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

The following set of patches attempt to fix the buffered write
locking problems. 

While looking at this deadlock, it became apparent that there are
several others which are equally bad or worse. It will be very
good to fix these.

I ceased to become an admirer of this problem when it stopped my
pagefault vs invalidate race fix from being merged!

Review and comments would be very nice. Testing only if you don't
value your data. I realise all filesystem developers are busy
solving the 10TB fsck problem now, but if you could please take a
minute to look at the fs/ changes, and also ensure your
filesystem's prepare and commit_write handlers aren't broken.

Sorry for the shotgun mail. It is your fault for ever being
mentioned in the same email as the buffered write deadlock ;)

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
