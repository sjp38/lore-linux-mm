Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0C86B007E
	for <linux-mm@kvack.org>; Sun, 27 Mar 2016 16:44:16 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id p65so79606633wmp.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 13:44:16 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id fy10si25256638wjc.144.2016.03.27.13.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 13:44:15 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id l68so79610687wml.0
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 13:44:14 -0700 (PDT)
Date: Sun, 27 Mar 2016 23:44:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Bloat caused by unnecessary calls to compound_head()?
Message-ID: <20160327204413.GB9638@node.shutemov.name>
References: <20160327203304.9695.qmail@ns.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160327203304.9695.qmail@ns.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: ebiggers3@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 27, 2016 at 04:33:04PM -0400, George Spelvin wrote:
> Could you just mark compound_head __pure?  That would tell the compiler
> that it's safe to re-use the return value as long as there is no memory
> mutation in between.
> 

Hm. It has some positive impact, but it's not dramatic. For instance,
mm/swap.o results:

add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-43 (-43)
function                                     old     new   delta
__page_cache_release                         319     298     -21
release_pages                                722     700     -22

mark_page_accessed() problem was not fixed by that.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
