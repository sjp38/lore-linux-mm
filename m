Date: Mon, 11 Aug 2008 16:01:14 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH for -mm 0/5] mlock return value rework
Message-Id: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

patch against: 2.6.27-rc1-mm1


Halesh Sadashiv reported 2.6.23.17 has a regression about mlock return value.

http://marc.info/?l=linux-kernel&m=121749977015397&w=2

it is already fixed.
but the test doesn't works on current -mm tree because split-lru patch
introduce another regression.

So, I try to rework to mlock return value behavior.

Lee-san, could you please review this patches?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
