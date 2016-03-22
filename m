Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8186B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 11:20:12 -0400 (EDT)
Received: by mail-ig0-f174.google.com with SMTP id av4so107159717igc.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 08:20:12 -0700 (PDT)
Received: from resqmta-po-02v.sys.comcast.net (resqmta-po-02v.sys.comcast.net. [2001:558:fe16:19:96:114:154:161])
        by mx.google.com with ESMTPS id x4si15473241igb.43.2016.03.22.08.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 08:20:11 -0700 (PDT)
Date: Tue, 22 Mar 2016 10:20:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] fs, mm: get rid of PAGE_CACHE_* and page_cache_{get,release}
 macros
In-Reply-To: <20160322104113.GA143214@black.fi.intel.com>
Message-ID: <alpine.DEB.2.20.1603221019350.18618@east.gentwo.org>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.20.1603211121210.26353@east.gentwo.org> <20160321163404.GA141069@black.fi.intel.com> <alpine.DEB.2.20.1603211155280.26653@east.gentwo.org> <20160321170655.GA141158@black.fi.intel.com>
 <alpine.DEB.2.20.1603211229060.26653@east.gentwo.org> <20160322104113.GA143214@black.fi.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, 22 Mar 2016, Kirill A. Shutemov wrote:

> > Should then not PAGE_CACHE_SIZE take a page parameter and return the
> > correct page size?
>
> Why? What would you achieve by this?
>
> We already have a way to find out size of page: compoun_order() or
> hpage_nr_pages().

Ok that makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
