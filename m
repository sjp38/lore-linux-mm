Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8099B6B0121
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 06:33:48 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so8475903wgh.39
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 03:33:48 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id gt9si10593897wib.76.2014.11.10.03.33.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 03:33:47 -0800 (PST)
From: Luis Henriques <luis.henriques@canonical.com>
Subject: [3.16.y-ckt extended stable] Patch "x86, pageattr: Prevent overflow in slow_virt_to_phys() for X86_PAE" has been added to staging queue
Date: Mon, 10 Nov 2014 11:33:45 +0000
Message-Id: <1415619225-13284-1-git-send-email-luis.henriques@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan Cui <decui@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, gregkh@linuxfoundation.org, linux-mm@kvack.org, olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, dave.hansen@intel.com, riel@redhat.com, Thomas Gleixner <tglx@linutronix.de>, Luis Henriques <luis.henriques@canonical.com>, kernel-team@lists.ubuntu.com

This is a note to let you know that I have just added a patch titled

    x86, pageattr: Prevent overflow in slow_virt_to_phys() for X86_PAE

to the linux-3.16.y-queue branch of the 3.16.y-ckt extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.16.y-queue

This patch is scheduled to be released in version 3.16.7-ckt1.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.16.y-ckt tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Luis

------
