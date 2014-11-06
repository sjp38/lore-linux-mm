Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D92596B0071
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 20:29:01 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id n3so119375wiv.8
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 17:29:01 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id u8si14103051wia.23.2014.11.05.17.29.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 17:29:01 -0800 (PST)
From: Kamal Mostafa <kamal@canonical.com>
Subject: [3.13.y.z extended stable] Patch "x86, pageattr: Prevent overflow in slow_virt_to_phys() for X86_PAE" has been added to staging queue
Date: Wed,  5 Nov 2014 17:28:57 -0800
Message-Id: <1415237337-27714-1-git-send-email-kamal@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan Cui <decui@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, gregkh@linuxfoundation.org, linux-mm@kvack.org, olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, dave.hansen@intel.com, riel@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Kamal Mostafa <kamal@canonical.com>, kernel-team@lists.ubuntu.com

This is a note to let you know that I have just added a patch titled

    x86, pageattr: Prevent overflow in slow_virt_to_phys() for X86_PAE

to the linux-3.13.y-queue branch of the 3.13.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.13.y-queue

This patch is scheduled to be released in version 3.13.11.11.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.13.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Kamal

------
