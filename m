Date: Fri, 15 Dec 2000 17:07:25 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: New patches for 2.2.18 raw IO (fix for fault retry)
Message-ID: <20001215170725.R11931@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Stephen Tweedie <sct@redhat.com>, Andi Kleen <ak@muc.de>, Andrea Arcangeli <andrea@suse.de>, wtenhave@sybase.com, hdeller@redhat.com, Eric Lowe <elowe@myrile.madriver.k12.oh.us>, Larry Woodman <woodman@missioncriticallinux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

OK, this now assembles the full outstanding set of raw IO fixes for
the final 2.2.18 kernel, both with and without the 4G bigmem patches.

The only changes since the last 2.2.18pre24 release are the addition
of a minor bugfix (possible failures when retrying after getting colliding
kiobuf mappings spanning two separate process virtual memory spaces),
and the addition by popular demand of the ability to unbind raw
devices (just bind them to 0,0 to unbind).

kiobuf-2.2.18.tar.gz has been uploaded to:

	ftp.uk.linux.org:/pub/linux/sct/fs/raw-io/
and	ftp.*.kernel.org:/pub/linux/kernel/people/sct/raw-io/

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
