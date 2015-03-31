Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id E37E66B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 09:11:04 -0400 (EDT)
Received: by iebmp1 with SMTP id mp1so7836701ieb.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 06:11:04 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id h12si5248237ioh.103.2015.03.31.06.11.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 06:11:04 -0700 (PDT)
Date: Tue, 31 Mar 2015 08:11:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: use PageAnon() and PageKsm() helpers in
 page_anon_vma()
In-Reply-To: <1427802647-16764-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.11.1503310810320.13959@gentwo.org>
References: <1427802647-16764-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>

On Tue, 31 Mar 2015, Kirill A. Shutemov wrote:

> Let's use PageAnon() and PageKsm() helpers instead. It helps readability
> and makes page_anon_vma() work correctly on tail pages.

But it adds a branch due to the use of ||.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
