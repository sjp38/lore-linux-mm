Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 71E956B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 13:08:06 -0400 (EDT)
Received: by qgej70 with SMTP id j70so24099997qge.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 10:08:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k7si2640297qcj.38.2015.05.07.10.08.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 10:08:05 -0700 (PDT)
Date: Thu, 7 May 2015 19:08:02 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
Message-ID: <20150507170802.GI13098@redhat.com>
References: <20150421120222.GC4481@redhat.com>
 <55389261.50105@parallels.com>
 <20150427211650.GC24035@redhat.com>
 <55425A74.3020604@parallels.com>
 <20150507134236.GB13098@redhat.com>
 <554B769E.1040000@parallels.com>
 <20150507143343.GG13098@redhat.com>
 <554B79C0.5060807@parallels.com>
 <20150507151136.GH13098@redhat.com>
 <554B82D4.4060809@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <554B82D4.4060809@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>

On Thu, May 07, 2015 at 06:20:52PM +0300, Pavel Emelyanov wrote:
> Yes. Longer message (type + 3 u64-s) and the ability to request for extra
> events is all I need. If you're OK with this being in the 0xAA API, then

This started from the request to get the full address (even if
personally I'm not convinced that the bits below PAGE_SHIFT can be
meaningful to userland) but I thought we could achieve both things and
hopefully this change is for the best.

Can you have a look at this and let me know if it looks ok?

http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=d7ba2f23bb978820aa04f1e338789669eff33a7d
http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/tree/fs/userfaultfd.c?h=userfault&id=d7ba2f23bb978820aa04f1e338789669eff33a7d
http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/tree/include/uapi/linux/userfaultfd.h?h=userfault&id=d7ba2f23bb978820aa04f1e338789669eff33a7d

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
