Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 99E546B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 10:50:50 -0400 (EDT)
Received: by igrv9 with SMTP id v9so30661647igr.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 07:50:50 -0700 (PDT)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id au1si7471868igc.31.2015.06.29.07.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 07:50:49 -0700 (PDT)
Date: Mon, 29 Jun 2015 09:50:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: fix status code move_pages() returns for zero page
In-Reply-To: <1435141428-98266-1-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.11.1506290947560.3164@east.gentwo.org>
References: <1435141428-98266-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Wed, 24 Jun 2015, Kirill A. Shutemov wrote:

> Man page for move_pages(2) specifies that status code for zero page is
> supposed to be -EFAULT. Currently kernel return -ENOENT in this case.
>
> follow_page() can do it for us, if we would ask for FOLL_DUMP.

FOLL_DUMP also has the consequence that the upper layer page tables pages
are no longer allocated.

Otherwise this looks ok.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
