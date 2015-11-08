Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3226B6B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 18:40:20 -0500 (EST)
Received: by wmnn186 with SMTP id n186so85065543wmn.1
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 15:40:19 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id v184si13356490wmd.49.2015.11.08.15.40.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 15:40:18 -0800 (PST)
Received: by wiby19 with SMTP id y19so6108884wib.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 15:40:18 -0800 (PST)
Date: Mon, 9 Nov 2015 01:40:16 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new
 THP refcounting
Message-ID: <20151108234016.GC29600@node.shutemov.name>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151105163211.608eec970de21a95faf6e156@linux-foundation.org>
 <20151106102921.GA6463@node.shutemov.name>
 <20151106143900.e61c38b5bf3e44547873d9d2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151106143900.e61c38b5bf3e44547873d9d2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>

On Fri, Nov 06, 2015 at 02:39:00PM -0800, Andrew Morton wrote:
> On Fri, 6 Nov 2015 12:29:21 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > > page_mapcount() is getting pretty bad too.
> > 
> > Do you want me to uninline slow path (PageCompound())?
> 
> I guess so.  Uninlining all of page_mapcount() does this:
> 
> gcc-4.4.4:
> 
>    text    data     bss     dec     hex filename
>  973702  273954  831512 2079168  1fb9c0 mm/built-in.o-before
>  970148  273954  831000 2075102  1fa9de mm/built-in.o-after
> 
> That's quite a bit of bloat.
> 
> I don't know why bss changed; this usually (always?) happens.  Seems
> bogus.

Here it is.
