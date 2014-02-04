Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CC74B6B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 15:43:52 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so8987343pab.30
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 12:43:52 -0800 (PST)
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
        by mx.google.com with ESMTPS id eb3si26024537pbc.266.2014.02.04.12.43.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 12:43:51 -0800 (PST)
Received: by mail-pb0-f41.google.com with SMTP id up15so9014541pbc.0
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 12:43:51 -0800 (PST)
From: Sebastian Capella <sebastian.capella@linaro.org>
Subject: [PATCH v7 0/3] hibernation related patches
Date: Tue,  4 Feb 2014 12:43:48 -0800
Message-Id: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Patchset related to hibernation resume:
  - enhancement to make the use of an existing resume file more general
  - add kstrdup_trimnl function which duplicates and trims a single
    trailing newline off of a string
  - cleanup checkpatch warnings in hibernate.c file

  All patches are based on the 3.13 tag.  This was tested on a
  Beaglebone black with partial hibernation support, and compiled for
  x86_64.

[PATCH v7 1/3] mm: add kstrdup_trimnl function
  include/linux/string.h |    1 +
  mm/util.c              |   29 +++++++++++++++++++++++++++++
  2 files changed, 30 insertions(+)

  Adds the kstrdup_trimnl function to duplicate and trim
  at most one trailing newline from a string.
  This is useful for working with user input to sysfs.

[PATCH v7 2/3] trivial: PM / Hibernate: clean up checkpatch in
  kernel/power/hibernate.c |   62 ++++++++++++++++++++++++----------------------
  1 file changed, 32 insertions(+), 30 deletions(-)

  Cleanup checkpatch warnings in kernel/power/hibernate.c

[PATCH v7 3/3] PM / Hibernate: use name_to_dev_t to parse resume
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


Changes in v7:
--------------
* Switch to trim only one trailing newline if present using kstrdup_trimnl
* remove kstrimdup patch
* add kstrdup_trimnl patch
* Add clean up patch for kernel/power/hibernate.c checkpatch warnings

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
