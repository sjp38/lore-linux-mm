Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 9C2086B005A
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 20:42:37 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 0/2] Add help info for CONFIG_MOVABLE_NODE and disable is by default
Date: Mon, 17 Dec 2012 09:41:26 +0800
Message-Id: <1355708488-2913-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, tangchen@cn.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, mingo@elte.hu, penberg@kernel.org
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The first patch adds help info for CONFIG_MOVABLE_NODE option.
The second patch disable this option by default.

change log v1 -> v2:
Fix spelling comments from Ingo.

Tang Chen (2):
  memory-hotplug: Add help info for CONFIG_MOVABLE_NODE option
  memory-hotplug: Disable CONFIG_MOVABLE_NODE option by default.

 mm/Kconfig |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
