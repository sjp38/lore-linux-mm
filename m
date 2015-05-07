Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4806B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 14:35:48 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so47178875pab.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 11:35:47 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id nb8si3822965pdb.122.2015.05.07.11.35.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 11:35:47 -0700 (PDT)
Message-ID: <554BB07B.4020404@parallels.com>
Date: Thu, 7 May 2015 21:35:39 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
References: <20150421120222.GC4481@redhat.com> <55389261.50105@parallels.com> <20150427211650.GC24035@redhat.com> <55425A74.3020604@parallels.com> <20150507134236.GB13098@redhat.com> <554B769E.1040000@parallels.com> <20150507143343.GG13098@redhat.com> <554B79C0.5060807@parallels.com> <20150507151136.GH13098@redhat.com> <554B82D4.4060809@parallels.com> <20150507170802.GI13098@redhat.com>
In-Reply-To: <20150507170802.GI13098@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>

On 05/07/2015 08:08 PM, Andrea Arcangeli wrote:
> On Thu, May 07, 2015 at 06:20:52PM +0300, Pavel Emelyanov wrote:
>> Yes. Longer message (type + 3 u64-s) and the ability to request for extra
>> events is all I need. If you're OK with this being in the 0xAA API, then
> 
> This started from the request to get the full address (even if
> personally I'm not convinced that the bits below PAGE_SHIFT can be
> meaningful to userland) but I thought we could achieve both things and
> hopefully this change is for the best.

:)

> Can you have a look at this and let me know if it looks ok?
> 
> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=d7ba2f23bb978820aa04f1e338789669eff33a7d
> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/tree/fs/userfaultfd.c?h=userfault&id=d7ba2f23bb978820aa04f1e338789669eff33a7d
> http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/tree/include/uapi/linux/userfaultfd.h?h=userfault&id=d7ba2f23bb978820aa04f1e338789669eff33a7d

Yup, this works for me, Now I can re-base my patches on it and check for the
features to contain FORK, REMAP and MADVDONTNEED and provide more info in 
the place now occupied with the uffd_msg.reserved fields. And all this w/o
introducing new API :)

Thanks!

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
