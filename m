Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 325B86B0039
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:12:15 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so3633113pbc.10
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:12:14 -0800 (PST)
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
        by mx.google.com with ESMTPS id yh9si7877998pab.150.2014.01.30.13.12.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 13:12:13 -0800 (PST)
Received: by mail-pb0-f53.google.com with SMTP id md12so3597230pbc.40
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:12:13 -0800 (PST)
From: Sebastian Capella <sebastian.capella@linaro.org>
Subject: 
Date: Thu, 30 Jan 2014 13:11:56 -0800
Message-Id: <1391116318-17253-1-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Patchset related to hibernation resume:
  - enhancement to make the use of an existing resume file more general
  - add kstrimdup function which trims and duplicates a string

  Both patches are based on the 3.13 tag.  This was tested on a
  Beaglebone black with partial hibernation support, and compiled for
  x86_64.

[PATCH v5 1/2] mm: add kstrimdup function
  include/linux/string.h |    1 +
  mm/util.c              |   30 ++++++++++++++++++++++++++++++
  2 files changed, 31 insertions(+)

  Adds the kstrimdup function to duplicate and trim whitespace
  from a string.  This is useful for working with user input to
  sysfs.

[PATCH v5 2/2] PM / Hibernate: use name_to_dev_t to parse resume
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
