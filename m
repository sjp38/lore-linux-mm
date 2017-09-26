Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD7236B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 15:19:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f84so19350673pfj.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:19:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l66sor2482802pfb.140.2017.09.26.12.19.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 12:19:07 -0700 (PDT)
From: Kyle Huey <me@kylehuey.com>
Subject: Re: [PATCH] mm: Fix typo in VM_MPX definition
Date: Tue, 26 Sep 2017 12:19:05 -0700
Message-Id: <20170926191905.24266-1-khuey@kylehuey.com>
In-Reply-To: <20170918140253.36856-1-kirill.shutemov@linux.intel.com>
References: <20170918140253.36856-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Robert O'Callahan <robert@ocallahan.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>

Could we get this patch into the next 4.14 rc too?  This "typo" causes a bunch
of sections in /proc/N/maps to be incorrectly labelled [mpx] which confuses rr.
We could probably work around if it we had to but doing this right is trivial.

Thanks,

- Kyle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
