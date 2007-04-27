Date: Fri, 27 Apr 2007 14:45:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] change global zonelist order v4 [0/2]
Message-Id: <20070427144530.ae42ee25.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, AKPM <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Hi, this is version 4. including Lee Schermerhon's good rework.
and automatic configuration at boot time.

(This patch is reworked from V2, so skip V3 changelog.)

ChangeLog V2 -> V4
- automatic configuration is added.
- automatic configuration is now default.
- relaxed_zone_order is renamed to be numa_zonelist_order
  you can specify value "default" , "zone" , "numa"
- clean-up from Lee Schermerhorn
- patch is speareted to "base" and "autoconfiguration algorithm"

Changelog from V1 -> V2
- sysctl name is changed to be relaxed_zone_order
- NORMAL->NORMAL->....->DMA->DMA->DMA order (new ordering) is now default.
  NORMAL->DMA->NORMAL->DMA order (old ordering) is optional.
- addes boot opttion to set relaxed_zone_order. ia64 is supported now.
- Added documentation


Please don't hesitate to rework this if you have good plan.
I'll be offlined in the next week because my office will be closed.
Lee-san, please Ack or Sign-Off if patches seems O.K.

I think my autoconfiguration logic is reasonable to some extent. But we may
have some discussion. It can be rewritable by additional patch easily.

Thanks.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
