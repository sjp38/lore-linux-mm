Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C060F6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 18:48:39 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so2427142pab.1
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 15:48:39 -0800 (PST)
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
        by mx.google.com with ESMTPS id n8si4275793pax.44.2014.01.29.15.48.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 15:48:38 -0800 (PST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so2408072pbb.39
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 15:48:38 -0800 (PST)
From: Sebastian Capella <sebastian.capella@linaro.org>
Subject: [PATCH v4 0/2] PM / Hibernate: sysfs resume
Date: Wed, 29 Jan 2014 15:48:22 -0800
Message-Id: <1391039304-3172-1-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Patchset related to hibernation resume:
  - enhancement to make the use of an existing resume file more general
  - add kstrimdup function which trims and duplicates a string

  Both patches are based on the 3.13 tag.  This was tested on a
  Beaglebone black with partial hibernation support, and compiled for
  x86_64.

[PATCH v4 1/2] mm: add kstrimdup function
  include/linux/string.h |    1 +
  mm/util.c              |   19 +++++++++++++++++++
  2 files changed, 20 insertions(+)

  Adds the kstrimdup function to duplicate and trim whitespace
  from a string.  This is useful for working with user input to
  sysfs.

[PATCH v4 2/2] PM / Hibernate: use name_to_dev_t to parse resume
  kernel/power/hibernate.c |   33
  +++++++++++++++++----------------
  1 file changed, 17 insertions(+), 16 deletions(-)

  Use name_to_dev_t to parse the /sys/power/resume file making the
  syntax more flexible.  It supports the previous use syntax
  and additionally can support other formats such as
  /dev/devicenode and UUID= formats.

  By changing /sys/debug/resume to accept the same syntax as
  the resume=device parameter, we can parse the resume=device
  in the initrd init script and use the resume device directly
  from the kernel command line.

Changes in v4:
--------------
* Dropped name_to_dev_t rework in favor of adding kstrimdup
* adjusted resume_store

Changes in v3:
--------------
* Dropped documentation patch as it went in through trivial
* Added patch for name_to_dev_t to support directly parsing userspace
  buffer

Changes in v2:
--------------
* Added check for null return of kstrndup in hibernate.c


Thanks,

Sebastian


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
