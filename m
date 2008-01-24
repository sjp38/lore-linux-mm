Date: Thu, 24 Jan 2008 13:18:01 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 0/8] mem_notify v5
Message-Id: <20080124130348.1760.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi

The /dev/mem_notify is low memory notification device.
it can avoid swappness and oom by cooperationg with the user process.

You need not be annoyed by OOM any longer :)
please any comments!

patch list
	[1/8] introduce poll_wait_exclusive() new API
	[2/8] introduce wake_up_locked_nr() new API
	[3/8] introduce /dev/mem_notify new device (the core of this patch series)
	[4/8] memory_pressure_notify() caller
	[5/8] add new mem_notify field to /proc/zoneinfo
	[6/8] (optional) fixed incorrect shrink_zone
	[7/8] ignore very small zone for prevent incorrect low mem notify.
	[8/8] support fasync feature


related discussion:
--------------------------------------------------------------
  LKML OOM notifications requirement discussion
     http://www.gossamer-threads.com/lists/linux/kernel/832802?nohighlight=1#832802
  OOM notifications patch [Marcelo Tosatti]
     http://marc.info/?l=linux-kernel&m=119273914027743&w=2
  mem notifications v3 [Marcelo Tosatti]
     http://marc.info/?l=linux-mm&m=119852828327044&w=2
  Thrashing notification patch  [Daniel Spang]
     http://marc.info/?l=linux-mm&m=119427416315676&w=2
  mem notification v4 [kosaki]
     http://marc.info/?l=linux-mm&m=120035840523718&w=2


Changelog
-------------------------------------------------
  v4 -> v5 (by KOSAKI Motohiro)
    o rebase to 2.6.24-rc8-mm1
    o change display order of /proc/zoneinfo
    o ignore very small zone
    o support fcntl(F_SETFL, FASYNC)
    o fix some trivial bugs.

  v3 -> v4 (by KOSAKI Motohiro)
    o rebase to 2.6.24-rc6-mm1
    o avoid wake up all.
    o add judgement point to __free_one_page().
    o add zone awareness.

  v2 -> v3 (by Marcelo Tosatti)
    o changes the notification point to happen whenever
      the VM moves an anonymous page to the inactive list.
    o implement notification rate limit.

  v1(oom notify) -> v2 (by Marcelo Tosatti)
    o name change
    o notify timing change from just swap thrashing to
      just before thrashing.
    o also works with swapless device.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
