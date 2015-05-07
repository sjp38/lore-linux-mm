Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9448B6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 09:42:40 -0400 (EDT)
Received: by qkx62 with SMTP id 62so27338379qkx.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 06:42:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n77si2016938qgn.64.2015.05.07.06.42.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 06:42:39 -0700 (PDT)
Date: Thu, 7 May 2015 15:42:36 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
Message-ID: <20150507134236.GB13098@redhat.com>
References: <5509D342.7000403@parallels.com>
 <20150421120222.GC4481@redhat.com>
 <55389261.50105@parallels.com>
 <20150427211650.GC24035@redhat.com>
 <55425A74.3020604@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55425A74.3020604@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>

Hi Pavel,

On Thu, Apr 30, 2015 at 07:38:12PM +0300, Pavel Emelyanov wrote:
> Hi,
> 
> This is (seem to be) the minimal thing that is required to unblock
> standard uffd usage from the non-cooperative one. Now more bits can
> be added to the features field indicating e.g. UFFD_FEATURE_FORK and
> others needed for the latter use-case.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.

http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=c2dee3384770a953cbad27b46854aa6fd13656c6
http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=d0df59f21f2cde4c49879c00586ce3cb1e3860fe

I was also asked if we could return the full address of the fault
including the page offset. In the end I also implemented this
incremental to your change:

http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=c308fc81b0a9c53c11b33331ad00d8e5b9763e60

Let me know if you're ok with it. The commit header explains more why
I think the bits below PAGE_SHIFT of the fault address aren't
interesting but why I did this change anyway.

After reviewing this last change I think it's time to make a proper
submit and it's polished enough for merging in -mm after proper review
of the full patchset.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
