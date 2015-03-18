Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 14B416B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 15:34:38 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so51359774pad.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:34:37 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ta2si37946419pab.0.2015.03.18.12.34.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 12:34:37 -0700 (PDT)
Message-ID: <5509D342.7000403@parallels.com>
Date: Wed, 18 Mar 2015 22:34:26 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] UserfaultFD: Extension for non cooperative uffd usage
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>
Cc: Sanidhya Kashyap <sanidhya.gatech@gmail.com>

Hi,

On the recent LSF Andrea presented his userfault-fd patches and
I had shown some issues that appear in usage scenarios when the
monitor task and mm task do not cooperate to each other on VM
changes (and fork()-s).

Here's the implementation of the extended uffd API that would help 
us to address those issues.

As proof of concept I've implemented only fix for fork() case, but
I also plan to add the mremap() and exit() notifications, both are
also required for such non-cooperative usage.

More details about the extension itself is in patch #2 and the fork()
notification description is in patch #3.

Comments and suggestion are warmly welcome :)


Andrea, what's the best way to go on with the patches -- would you
prefer to include them in your git tree or should I instead continue
with them on my own, re-sending them when required? Either way would
be OK for me.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
