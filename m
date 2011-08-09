Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 02A076B016D
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 05:48:08 -0400 (EDT)
Received: by ewy9 with SMTP id 9so1135927ewy.14
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 02:48:06 -0700 (PDT)
From: Per Forlin <per.forlin@linaro.org>
Subject: [PATCH --mmotm v6 0/3] Make fault injection available for MMC IO
Date: Tue,  9 Aug 2011 11:47:45 +0200
Message-Id: <1312883268-4342-1-git-send-email-per.forlin@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>, akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>
Cc: linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org, Per Forlin <per.forlin@linaro.org>

change log:
 v2 - Resolve build issue in mmc core.c due to multiple init_module by
      removing the fault inject module.
    - Export fault injection functions to make them available for modules
    - Update fault injection documentation on MMC IO  
 v3 - add function descriptions in core.c
    - use export GPL for fault injection functions
 v4 - make the fault_attr per host. This prepares for upcoming patch from
      Akinobu that adds support for creating debugfs entries in
      arbitrary directory.
 v5 - Make use of fault_create_debugfs_attr() in Akinobu's
      patch "fault-injection: add ability to export fault_attr in...". 
 v6 - Fix typo in commit message in patch "export fault injection functions"

Per Forlin (3):
  fault-inject: export fault injection functions
  mmc: core: add random fault injection
  fault injection: add documentation on MMC IO fault injection

 Documentation/fault-injection/fault-injection.txt |    5 ++
 drivers/mmc/core/core.c                           |   44 +++++++++++++++++++++
 drivers/mmc/core/debugfs.c                        |   24 +++++++++++
 include/linux/mmc/host.h                          |    7 +++
 lib/Kconfig.debug                                 |   11 +++++
 lib/fault-inject.c                                |    2 +
 6 files changed, 93 insertions(+), 0 deletions(-)

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
