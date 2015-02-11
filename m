Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2DEAF6B006E
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 15:00:17 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id bs8so7740063wib.4
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:00:16 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id t1si3271025wje.69.2015.02.11.12.00.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 12:00:14 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id bs8so7739777wib.4
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:00:14 -0800 (PST)
Date: Wed, 11 Feb 2015 12:00:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm: move mm_populate()-related code to mm/gup.c
In-Reply-To: <1423674728-214192-5-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1502111158360.9656@chino.kir.corp.google.com>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com> <1423674728-214192-5-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Wed, 11 Feb 2015, Kirill A. Shutemov wrote:

> It's odd that we have populate_vma_page_range() and __mm_populate() in
> mm/mlock.c. It's implementation of generic memory population and
> mlocking is one of possible side effect, if VM_LOCKED is set.
> 
> __get_user_pages() is core of the implementation. Let's move the code
> mm/gup.c.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: David Rientjes <rientjes@google.com>

Nice cleanup!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
