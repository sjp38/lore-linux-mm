Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 80B326B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 15:41:15 -0500 (EST)
Received: by wicll6 with SMTP id ll6so97742804wic.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 12:41:15 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id i19si5597884wmc.95.2015.11.04.12.41.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 12:41:14 -0800 (PST)
Received: by wmnn186 with SMTP id n186so1873087wmn.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 12:41:14 -0800 (PST)
Date: Wed, 4 Nov 2015 22:41:12 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 5/5] mm, page_owner: dump page owner info from dump_page()
Message-ID: <20151104204112.GA7614@node.shutemov.name>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
 <1446649261-27122-6-git-send-email-vbabka@suse.cz>
 <20151104194104.GB13303@node.shutemov.name>
 <563A66B7.5090102@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563A66B7.5090102@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Wed, Nov 04, 2015 at 03:12:39PM -0500, Sasha Levin wrote:
> On 11/04/2015 02:41 PM, Kirill A. Shutemov wrote:
> >> +	dump_page_owner(page);
> > I tend to put dump_page() into random places during debug. Dumping page
> > owner for all dump_page() cases can be too verbose.
> > 
> > Can we introduce dump_page_verbose() which would do usual dump_page() plus
> > dump_page_owner()?
> > 
> 
> Is there any existing piece of code that would use dump_page() rather than
> dump_page_verbose()?

Good point. I think not.

So we can leave dump_page() with dump_page_owner() stuff and have
__dump_page() or something as lighter version.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
