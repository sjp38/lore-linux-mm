Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87B608E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 06:12:04 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id t79-v6so9472836wmt.3
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 03:12:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t66-v6sor8652595wmg.28.2018.09.24.03.12.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 03:12:02 -0700 (PDT)
From: Bartosz Golaszewski <brgl@bgdev.pl>
Subject: [PATCH v3 0/4] devres: provide and use devm_kstrdup_const()
Date: Mon, 24 Sep 2018 12:11:46 +0200
Message-Id: <20180924101150.23349-1-brgl@bgdev.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartosz Golaszewski <brgl@bgdev.pl>

This series implements devm_kstrdup_const() together with some
prerequisite changes and uses it in pmc-atom driver.

v1 -> v2:
- fixed the changelog in the patch implementing devm_kstrdup_const()
- fixed the kernel doc
- moved is_kernel_rodata() to asm-generic/sections.h
- fixed constness

v2 -> v3:
- rebased on top of 4.19-rc5 as there were some conflicts in the
  pmc-atom driver
- collected Reviewed-by tags

Bartosz Golaszewski (4):
  devres: constify p in devm_kfree()
  mm: move is_kernel_rodata() to asm-generic/sections.h
  devres: provide devm_kstrdup_const()
  clk: pmc-atom: use devm_kstrdup_const()

 drivers/base/devres.c          | 43 ++++++++++++++++++++++++++++++++--
 drivers/clk/x86/clk-pmc-atom.c | 19 ++++-----------
 include/asm-generic/sections.h | 14 +++++++++++
 include/linux/device.h         |  5 +++-
 mm/util.c                      |  7 ------
 5 files changed, 63 insertions(+), 25 deletions(-)

-- 
2.18.0
