Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 11DFC82966
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 17:23:47 -0400 (EDT)
Received: by mail-yk0-f177.google.com with SMTP id q200so5397571ykb.8
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 14:23:45 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id n1si9495982yhm.159.2014.04.11.14.23.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 14:23:45 -0700 (PDT)
Message-ID: <1397251420.2503.25.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] [v2] mm: pass VM_BUG_ON() reason to dump_page()
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 11 Apr 2014 14:23:40 -0700
In-Reply-To: <20140411204232.C8CF1A7A@viggo.jf.intel.com>
References: <20140411204232.C8CF1A7A@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com

On Fri, 2014-04-11 at 13:42 -0700, Dave Hansen wrote:
> Changes from v1:
>  * Fix tabs before spaces in the multi-line #define
> 
> --
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I recently added a patch to let folks pass a "reason" string
> dump_page() which gets dumped out along with the page's data.
> This essentially saves the bug-reader a trip in to the source
> to figure out why we BUG_ON()'d.
> 
> The new VM_BUG_ON_PAGE() passes in NULL for "reason".  It seems
> like we might as well pass the BUG_ON() condition if we have it.
> This will bloat kernels a bit with ~160 new strings, but this
> is all under a debugging option anyway.
> 
> 	page:ffffea0008560280 count:1 mapcount:0 mapping:(null) index:0x0
> 	page flags: 0xbfffc0000000001(locked)
> 	page dumped because: VM_BUG_ON_PAGE(PageLocked(page))
> 	------------[ cut here ]------------
> 	kernel BUG at /home/davehans/linux.git/mm/filemap.c:464!
> 	invalid opcode: 0000 [#1] SMP
> 	CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.14.0+ #251
> 	Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> 	...
> 
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
