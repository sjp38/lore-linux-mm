Message-Id: <3.0.6.32.20030115004522.007e5100@boo.net>
Date: Wed, 15 Jan 2003 00:45:22 -0500
From: Jason Papadopoulos <jasonp@boo.net>
Subject: [PATCH] page coloring for 2.4.20 kernel, version 2
In-Reply-To: <3.0.6.32.20030105150405.007dead0@boo.net>
References: <20030105193411.GJ9704@holomorphy.com>
 <200301051603.LAA18650@boo-mda02.boo.net>
 <200301051603.LAA18650@boo-mda02.boo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Version 2 of the page coloring patch is ready. This version includes 
support for non-power-of-two cache sizes, fixes the ia64 cache detection 
code (thanks due to Alex Williamson), and fixes a small initialization bug.

New patch available at

www.boo.net/~jasonp/page_color-2.4.20-20030114.patch

Thanks in advance,
jasonp
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
