Message-ID: <3961A761.974CED49@norran.net>
Date: Tue, 04 Jul 2000 10:59:13 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: 2.4.0-test3-pre2: corruption in mm?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

When I booted up today mount complained that one of my disks
was not ok. (/usr)

e2fsck complained that it could not run automatically.
(It was properly shut down)

Rescue reboot and manual e2fsck made it ok again.


Sorry about the undetailed report...

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
