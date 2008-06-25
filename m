Date: Wed, 25 Jun 2008 18:59:34 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [-mm][PATCH 0/10]  memory related bugfix set for 2.6.26-rc5-mm3 v2
Message-Id: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi, Andrew and mm guys!

this is mm related fixes patchset for 2.6.26-rc5-mm3 v2.

Unfortunately, this version has several bugs and 
some bugs depend on each other.
So, I collect, sort, and fold these patchs.


btw: I wrote "this patch still crashed" last midnight.
but it works well today.
umm.. I was dreaming?

Anyway, I believe this patchset improve robustness and
provide better testing baseline.

enjoy!


Andrew, this patchset is my silver-spoon.
if you like it, I'm glad too.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
