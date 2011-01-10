Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 06D0B6B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 17:32:16 -0500 (EST)
Date: Mon, 10 Jan 2011 23:31:54 +0100
From: Matthias Merz <linux@merz-ka.de>
Subject: Regression in linux 2.6.37: failure to boot, caused by commit
	37d57443d5 (mm/slub.c)
Message-ID: <20110110223154.GA9739@merz.inka.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Tero Roponen <tero.roponen@gmail.com>
List-ID: <linux-mm.kvack.org>

Hello together,

I hope, I've got the right list of people from scripts/get_maintainer.pl
and the commit-log, just omitting LKML as Rcpt.

This morning I tried vanilla 2.6.37 on my Desktop system, which failed
to boot but continued displaying Debug-Messages too fast to read. Using
netconsole I was then able to capture them (see attached file). I was
able to trigger this bug even with init=/bin/bash by a simple call of
"mount -o remount,rw /" with my / being an ext4 filesystem.

Using git bisect I could identify commit 37d57443d5 as "the culprit" -
once I reverted that bugfix locally, my system booted happily. This ist
surely not a fix, but a local workaround for me - I would appreciate, if
someone with knowledge of the code could find a real fix.

The attached dmesg-output was "anonymized" wrt. MAC-Addresses, but is
complete otherwise.


Please let me know, if I can help any further,
thanks in advance,
Yours
Matthias Merz

-- 
Q: How many mutt users does it take to change a lightbulb?
A: One. But you have to set the option auto-change-illumination
   in your .muttrc file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
