Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 455686B0069
	for <linux-mm@kvack.org>; Sun,  9 Oct 2016 18:30:33 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x23so27634855lfi.0
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 15:30:33 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id j77si939903lfj.221.2016.10.09.15.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Oct 2016 15:30:31 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id b75so93868173lfg.3
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 15:30:31 -0700 (PDT)
Date: Mon, 10 Oct 2016 01:30:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at mm/huge_memory.c:1187!
Message-ID: <20161009223027.GA3964@node.shutemov.name>
References: <CACygaLCEsdDyERUACBqMfqupbvPyH7QOCcm3sE8nZuYbwfA=sQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACygaLCEsdDyERUACBqMfqupbvPyH7QOCcm3sE8nZuYbwfA=sQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wenwei Tao <ww.tao0320@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Oct 09, 2016 at 03:24:27PM +0800, Wenwei Tao wrote:
> Hi,
> 
> I open the Transparent  huge page and run the system and hit the bug
> in huge_memory.c:
> 
> static void __split_huge_page_refcount(struct page *page)
>                               .
>                               .
>                               .
> 
>      /* tail_page->_mapcount cannot change */
>      BUG_ON(page_mapcount(page_tail) < 0);
>                                .
>                                .
> 
> In my understanding, the THP's tail page's mapcount is initialized to
> -1,  page_mapcout(page_tail) should be 0.
> Did anyone meet the same issue?
> 
> Thanks.
> 
> 2016-09-28 02:12:08 [810422.485203] ------------[ cut here ]------------
> 2016-09-28 02:12:08 [810422.489974] kernel BUG at mm/huge_memory.c:1187!
> 2016-09-28 02:12:08 [810422.494742] invalid opcode: 0000 [#1] SMP
> 2016-09-28 02:12:08 [810422.499034] last sysfs file:
> /sys/devices/system/cpu/online
> 2016-09-28 02:12:08 [810422.504757] CPU 31
> 2016-09-28 02:12:08 [810422.506775] Modules linked in: 8021q garp
> bridge stp llc dell_rbu ipmi_devintf ipmi_si ipmi_msghandler bonding
> ipv6 microcode  dca power_meter ext4 mbcache jbd2 ahci wmi dm_mirror
> dm_region_hash dm_log dm_mod
> 2016-09-28 02:12:08 [810422.571439]
> 2016-09-28 02:12:08 [810422.573088] Pid: 10729, comm: observer
> Tainted: G        W  ----------------   2.6.32-220.23.2.el6.x86_64

The kernel is already tianted with warning.

And that is way to old kernel -- from RHEL 6.2, almost 5 years old.
Contact your OS vendor.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
