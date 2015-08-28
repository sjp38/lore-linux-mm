Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EC60E6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 11:13:34 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so27219674pad.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:13:34 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id i10si10414921pdn.70.2015.08.28.08.13.33
        for <linux-mm@kvack.org>;
        Fri, 28 Aug 2015 08:13:34 -0700 (PDT)
Message-ID: <55E07A8E.3030808@intel.com>
Date: Fri, 28 Aug 2015 08:13:18 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] userfaultfd21 updates v2
References: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>

Hi Andrea,

Is there a way you can think of to use userfaultfd without having a
separate thread to sit there and be watching the file descriptor?  The
current model doesn't seem like it would be possible to use with a
single-threaded app, for instance.

Is there a reason we couldn't generate a signal and then have the
userfaultfd handling done inside the signal handler?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
