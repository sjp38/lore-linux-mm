Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 286AB280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 03:40:50 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p75so555373wmg.2
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 00:40:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w51sor498542edd.54.2017.11.07.00.40.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 00:40:49 -0800 (PST)
Date: Tue, 7 Nov 2017 11:40:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: UBSAN: Undefined behaviour in mm/sparse.c:81:17
Message-ID: <20171107084045.clzrn32pvsw4jthi@node.shutemov.name>
References: <20171105125733.GA17434@Red>
 <20171106192759.GA29097@Red>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106192759.GA29097@Red>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, yasu.isimatu@gmail.com, richard.weiyang@gmail.com, gregkh@linuxfoundation.org, dave.hansen@linux.intel.com, linux-kernel@vger.kernel.org

On Mon, Nov 06, 2017 at 08:27:59PM +0100, Corentin Labbe wrote:
> Hello
> 
> Disabling UBSAN, does not change anything (NULL ptr dereference).
> Reverting 83e3c48729d9ebb7af5a31a504f3fd6aff0348c4 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y") made the boot progress further.
> 
> Regards
> 
> PS: I have added more "TO" people according to get_maintainer.pl mm/sparse.c
> 

See

http://lkml.kernel.org/r/20171107083337.89952-1-kirill.shutemov@linux.intel.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
