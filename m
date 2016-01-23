Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2380F6B0005
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 02:54:21 -0500 (EST)
Received: by mail-lf0-f45.google.com with SMTP id m198so59686695lfm.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:54:21 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id d141si4533282lfe.123.2016.01.22.23.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 23:54:20 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id n70so5250777lfn.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 23:54:19 -0800 (PST)
Date: Sat, 23 Jan 2016 10:54:15 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2] mm: do not limit VmData with RLIMIT_DATA
Message-ID: <20160123075415.GH2262@uranus>
References: <145353478067.23962.14991739413777907906.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145353478067.23962.14991739413777907906.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

On Sat, Jan 23, 2016 at 10:39:40AM +0300, Konstantin Khlebnikov wrote:
> This partially reverts 84638335900f ("mm: rework virtual memory accounting")
> 
> Before that commit RLIMIT_DATA have control only over size of the brk region.
> But that change have caused problems with all existing versions of valgrind
> because they set RLIMIT_DATA to zero for some reason.
> 
> More over, current check has a major flaw: RLIMIT_DATA in bytes,
> not pages. So, some problems might have slipped through testing.
> Let's revert it for now and put back in next release.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Link: http://lkml.kernel.org/r/20151228211015.GL2194@uranus
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>

Looks great for me. Thanks a lot, Kostya!
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
