Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3386B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 10:52:20 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so52989000pab.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 07:52:20 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sf10si27388947pbc.111.2015.05.13.07.52.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 07:52:19 -0700 (PDT)
Message-ID: <5553651B.1020909@parallels.com>
Date: Wed, 13 May 2015 17:52:11 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 0/5] UserfaultFD: Extension for non cooperative uffd usage
 (v2)
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

Hi,

This set is to address the issues that appear in userfaultfd usage
scenarios when the task monitoring the uffd and the mm-owner do not 
cooperate to each other on VM changes such as remaps, madvises and 
fork()-s.

This is the re-based set on the recent userfaultfd branch, two major
changes are:

* No need in separate API version, the uffd_msg introduced in the
  current code and UFFD_API ioctl are enough for the needed extentions
* Two events added -- for mremap() and madvise() MADV_DONTNEED

More details about the particular events are in patches 3 trough 4.
Comments and suggestion are warmly welcome :)

The v1 discussion thread is here: https://lkml.org/lkml/2015/3/18/729

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
