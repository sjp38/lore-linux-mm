Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 76BE36B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 19:54:19 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so3844434pad.27
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:54:19 -0800 (PST)
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
        by mx.google.com with ESMTPS id x3si8379471pbk.293.2014.01.30.16.54.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 16:54:18 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id y10so3663441pdj.18
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:54:18 -0800 (PST)
From: Sebastian Capella <sebastian.capella@linaro.org>
Subject: [PATCH v6 0/2] hibernation related patches
Date: Thu, 30 Jan 2014 16:54:12 -0800
Message-Id: <1391129654-12854-1-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Patchset related to hibernation resume:
  - enhancement to make the use of an existing resume file more general
  - add kstrimdup function which trims and duplicates a string

  Both patches are based on the 3.13 tag.  This was tested on a
  Beaglebone black with partial hibernation support, and compiled for
  x86_64.

[PATCH v6 1/2] mm: add kstrimdup function
  include/linux/string.h |    1 +
  mm/util.c              |   30 ++++++++++++++++++++++++++++++
  2 files changed, 31 insertions(+)

  Adds the kstrimdup function to duplicate and trim whitespace
  from a string.  This is useful for working with user input to
  sysfs.

[PATCH v6 2/2] PM / Hibernate: use name_to_dev_t to parse resume
  kernel/power/hibernate.c |   33 +++++++++++++++++----------------
  1 file changed, 17 insertions(+), 16 deletions(-)

  Use name_to_dev_t to parse the /sys/power/resume file making the
  syntax more flexible.  It supports the previous use syntax
  and additionally can support other formats such as
  /dev/devicenode and UUID= formats.

  By changing /sys/debug/resume to accept the same syntax as
  the resume=device parameter, we can parse the resume=device
  in the initrd init script and use the resume device directly
  from the kernel command line.

Changes in v6:
--------------
* Revert tricky / confusing while loop indexing

Changes in v5:
--------------
* Change kstrimdup to minimize allocated memory.  Now allocates only
  the memory needed for the string instead of using strim.

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
