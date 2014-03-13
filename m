Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id CF4426B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 16:46:27 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id e89so4618290qgf.5
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 13:46:27 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id k4si912111qci.42.2014.03.13.13.46.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 13:46:26 -0700 (PDT)
Received: by mail-qc0-f175.google.com with SMTP id e16so1857416qcx.20
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 13:46:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACz4_2eYUOkHdOtBJGDGMMwBcQkyPs8BDXQ491Ab_ig4z8q5mQ@mail.gmail.com>
References: <1393625931-2858-1-git-send-email-quning@google.com> <CACz4_2eYUOkHdOtBJGDGMMwBcQkyPs8BDXQ491Ab_ig4z8q5mQ@mail.gmail.com>
From: Ning Qu <quning@google.com>
Date: Thu, 13 Mar 2014 13:46:04 -0700
Message-ID: <CACz4_2fD=GErMJB3+NJFfhdV_vmPeWTg17J+KOGw17BLN9dBTQ@mail.gmail.com>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if they
 are in page cache
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

Hi, Andrew,

I have updated the results for tmpfs last week and Hugh already ack
this patchset on Mar 4 in "[PATCH 1/1] mm: implement ->map_pages for
shmem/tmpfs"

Acked-by: Hugh Dickins <hughd@google.com>

Please consider to apply this patch so that tmpfs will have the
similar feature together with the other file systems. Thanks a lot!

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
