Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id F2C3D6B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 12:00:24 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id hi5so8603414wib.8
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 09:00:24 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id l2si11141188een.167.2014.01.10.09.00.21
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 09:00:22 -0800 (PST)
Date: Fri, 10 Jan 2014 19:00:16 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1440!
Message-ID: <20140110170016.GA5179@node.dhcp.inet.fi>
References: <52B88F6E.8070909@oracle.com>
 <20131223200255.GA18521@node.dhcp.inet.fi>
 <52B8AAFD.5090401@oracle.com>
 <52C819E2.8090509@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52C819E2.8090509@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Sat, Jan 04, 2014 at 09:25:38AM -0500, Sasha Levin wrote:
> On 12/23/2013 04:28 PM, Sasha Levin wrote:
> >On 12/23/2013 03:02 PM, Kirill A. Shutemov wrote:
> >>>[  265.474585] kernel BUG at mm/huge_memory.c:1440!
> >>Could you dump_page() on the bug?
> >
> >[  469.007946] page:ffffea0005bd8000 count:3 mapcount:0 mapping:ffff8800bcd3d171 index: 0x7fca81000
> >[  469.009362] page flags: 0x2afffff80090018(uptodate|dirty|swapcache|swapbacked)
> 
> Ping? It still shows up in 3.13-rc6.

Sorry, I don't have a theory why it can happen. And I can't reproduce it.

Is there chance to get trinity log after the crash?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
