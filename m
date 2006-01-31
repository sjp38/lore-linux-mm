From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060131023000.7915.71955.sendpatchset@debian>
In-Reply-To: <20060119080408.24736.13148.sendpatchset@debian>
References: <20060119080408.24736.13148.sendpatchset@debian>
Subject: [PATCH 0/8] Pzone based CKRM memory resource controller
Date: Tue, 31 Jan 2006 11:30:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

I've split the patches into smaller pieces in order to increase
readability.  The core part of the patchset is the fifth one with
the subject "Add the pzone_create() function."

Changes since the last post:
* Fixed a bug that pages allocated with __GFP_COLD are incorrectly handled.
* Moved the PZONE bit in page flags next to the zone number bits in 
  order to make changes by pzones smaller.
* Moved the nr_zones locking functions outside of the CONFIG_PSEUDO_ZONE
  because they are not directly related to pzones.

Thanks,

-- 
KUROSAWA, Takahiro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
