Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B6E7A6B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 08:28:54 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so12539667pdj.16
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 05:28:54 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id rx7si15934796pac.128.2014.08.12.05.28.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 05:28:53 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so12916951pad.36
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 05:28:53 -0700 (PDT)
Message-ID: <1407846532.10122.66.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: x86: vmalloc and THP
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Aug 2014 05:28:52 -0700
In-Reply-To: <20140812060745.GA7987@node.dhcp.inet.fi>
References: <53E99F86.5020100@scalemp.com>
	 <20140812060745.GA7987@node.dhcp.inet.fi>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Oren Twaig <oren@scalemp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Shai Fultheim
	(Shai@ScaleMP.com)" <Shai@scalemp.com>

On Tue, 2014-08-12 at 09:07 +0300, Kirill A. Shutemov wrote:
> On Tue, Aug 12, 2014 at 08:00:54AM +0300, Oren Twaig wrote:

> >Does memory allocated using vmalloc() will be mapped using huge
> >pages either directly or later by THP ? 
> 
> No. It's neither aligned properly, nor physically contiguous.
> 
> >If not, is there any fast way to change this behavior ? Maybe by
> >changing the granularity/alignment of such allocations to allow such
> >mapping ?
> 
> What's the point to use vmalloc() in this case?

Look at various large hashes we have in the system, all using
vmalloc() :

[    0.006856] Dentry cache hash table entries: 16777216 (order: 15, 134217728 bytes)
[    0.033130] Inode-cache hash table entries: 8388608 (order: 14, 67108864 bytes)
[    1.197621] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)

I would imagine a performance difference if we were using hugepages.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
