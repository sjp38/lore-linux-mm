Message-ID: <3E771BE0.3000308@aitel.hist.no>
Date: Tue, 18 Mar 2003 14:15:12 +0100
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.65-mm1
References: <20030318031104.13fb34cc.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.5.65-mm1 seems to work fine on my up office machine.

Using devfs is no problem with debian unstable/testing.
No config files needed to be changed compared to "normal" devfs.
Three files needed changing compared to plain old  non-devfs:
/etc/fstab:   use /dev/discs/disc0/partX instead /dev/hdaX
/etc/gpm:     use mouse device /dev/input/mouse0 instead of /dev/psaux
/etc/inittab: Specify vc/X instead of ttyX for getty. X came up even
without this.

Helge Hafting



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
