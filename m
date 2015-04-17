Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5E557900018
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 06:48:46 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so140703266qkg.1
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 03:48:46 -0700 (PDT)
Received: from mail-qc0-x22e.google.com (mail-qc0-x22e.google.com. [2607:f8b0:400d:c01::22e])
        by mx.google.com with ESMTPS id 40si11241837qkv.70.2015.04.17.03.48.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 03:48:45 -0700 (PDT)
Received: by qcrf4 with SMTP id f4so21379941qcr.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 03:48:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150417002847.1f5febf7@yak.slack>
References: <20150416032316.00b79732@yak.slack>
	<CALYGNiPM0KgRvu2EP+h0UT8ZzSeBpNOwR04-BX2vPFnn2xLN_w@mail.gmail.com>
	<CANq1E4SbenR0-N4oLBMUe_2iiduU1TReA1RRTMA9_+h_mGwNOw@mail.gmail.com>
	<20150417002847.1f5febf7@yak.slack>
Date: Fri, 17 Apr 2015 12:48:44 +0200
Message-ID: <CANq1E4RebX=feEtgpHa4v_C_PkKwDmDWG+jm98kUUj5yYV4ipg@mail.gmail.com>
Subject: Re: [PATCH] mm/shmem.c: Add new seal to memfd: F_SEAL_WRITE_NONCREATOR
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Tirado <mtirado418@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>

Hi

On Fri, Apr 17, 2015 at 6:28 AM, Michael Tirado <mtirado418@gmail.com> wrote:
> On Thu, 16 Apr 2015 14:01:07 +0200
> David Herrmann <dh.herrmann@gmail.com> wrote:
>> The same functionality of F_SEAL_WRITE_NONCREATOR can be achieved by
>> opening /proc/self/fd/<num> with O_RDONLY. Just pass that read-only FD
>> to your peers but retain the writable one. But note that you must
>> verify your peers do not have the same uid as you do, otherwise they
>> can just gain a writable descriptor by opening /proc/self/fd/<num>
>> themselves.
>
> My peers may be any uid,

Where's the problem? Just pass the read-only file-descriptor to your
peers and make sure the access-mode of the memfd is 0600. No other
user will be able to gain a writable file-descriptor, but you.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
