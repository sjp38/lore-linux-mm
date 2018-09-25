Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38B9A8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:49:00 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id m15-v6so46468622ioj.22
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:49:00 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0101.hostedemail.com. [216.40.44.101])
        by mx.google.com with ESMTPS id s16-v6si1676974ioa.88.2018.09.25.08.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 08:48:59 -0700 (PDT)
Message-ID: <a729cfd1102ef280650074dd8bec32c6b12636db.camel@perches.com>
Subject: Re: [PATCH v4 0/4] devres: provide and use devm_kstrdup_const()
From: Joe Perches <joe@perches.com>
Date: Tue, 25 Sep 2018 08:48:52 -0700
In-Reply-To: <c25df148-718a-d29d-9c1d-20701a0e4534@arm.com>
References: <20180925124629.20710-1-brgl@bgdev.pl>
	 <c25df148-718a-d29d-9c1d-20701a0e4534@arm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>, Bartosz Golaszewski <brgl@bgdev.pl>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael
 J . Wysocki" <rafael@kernel.org>, Jassi Brar <jassisinghbrar@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Arnd Bergmann <arnd@arndb.de>, Ulf Hansson <ulf.hansson@linaro.org>, Rob Herring <robh@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, Arend van Spriel <aspriel@gmail.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Bjorn Andersson <bjorn.andersson@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tue, 2018-09-25 at 13:51 +0100, Robin Murphy wrote:
> On 25/09/18 13:46, Bartosz Golaszewski wrote:
> > This series implements devm_kstrdup_const() together with some
> > prerequisite changes and uses it in pmc-atom driver.
> 
> Is anyone expecting me to review this series,

Probably not.

> or am I just here because 
> I once made a couple of entirely unrelated changes to device.h?

Most likely yes.

It is likely that Bartosz should update his use of the
get_maintainer.pl script to add "--nogit --nogit-fallback"
so drive-by patch submitters are not also cc'd on these
sorts of series.

$ ./scripts/get_maintainer.pl -f \
	drivers/base/devres.c \
	drivers/mailbox/tegra-hsp.c \
	include/asm-generic/sections.h \
	include/linux/device.h \
	mm/util.c | \
  wc -l
26

$ ./scripts/get_maintainer.pl -f --nogit --nogit-fallback \
	drivers/base/devres.c \
	drivers/mailbox/tegra-hsp.c \
	include/asm-generic/sections.h \
	include/linux/device.h \
	mm/util.c | \
  wc -l
10
