Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 157A46B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 13:29:36 -0400 (EDT)
Received: by mail-io0-f174.google.com with SMTP id o5so133235796iod.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:29:36 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id e141si11854698ioe.4.2016.03.21.10.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 10:29:35 -0700 (PDT)
Date: Mon, 21 Mar 2016 12:29:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] fs, mm: get rid of PAGE_CACHE_* and page_cache_{get,release}
 macros
In-Reply-To: <20160321170655.GA141158@black.fi.intel.com>
Message-ID: <alpine.DEB.2.20.1603211229060.26653@east.gentwo.org>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1603211121210.26353@east.gentwo.org> <20160321163404.GA141069@black.fi.intel.com> <alpine.DEB.2.20.1603211155280.26653@east.gentwo.org>
 <20160321170655.GA141158@black.fi.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 21 Mar 2016, Kirill A. Shutemov wrote:

> We do have two page sizes in the page cache. It's the only option to get
> transparent huge pages transparent.

Should then not PAGE_CACHE_SIZE take a page parameter and return the
correct page size?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
