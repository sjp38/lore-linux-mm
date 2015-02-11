Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 20DB96B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:59:28 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id h11so3184391wiw.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 11:59:27 -0800 (PST)
Received: from mail-we0-x22b.google.com (mail-we0-x22b.google.com. [2a00:1450:400c:c03::22b])
        by mx.google.com with ESMTPS id lh1si3238365wjb.88.2015.02.11.11.59.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 11:59:26 -0800 (PST)
Received: by mail-we0-f171.google.com with SMTP id p10so5757745wes.2
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 11:59:26 -0800 (PST)
Date: Wed, 11 Feb 2015 11:59:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mm: rename FOLL_MLOCK to FOLL_POPULATE
In-Reply-To: <1423674728-214192-2-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1502111145200.9656@chino.kir.corp.google.com>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com> <1423674728-214192-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Wed, 11 Feb 2015, Kirill A. Shutemov wrote:

> After commit a1fde08c74e9 FOLL_MLOCK has lost its original meaning: we
> don't necessary mlock the page if the flags is set -- we also take
> VM_LOCKED into consideration.
> 

s/necessary/necessarily/

> Since we use the same codepath for __mm_populate(), let's rename
> FOLL_MLOCK to FOLL_POPULATE.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
