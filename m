Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E52A6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 12:37:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so85723354wme.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 09:37:38 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id he7si32194081wjb.279.2016.08.01.09.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 09:37:37 -0700 (PDT)
Date: Mon, 1 Aug 2016 12:37:31 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [4.7+] various memory corruption reports.
Message-ID: <20160801163731.xmlcb7vi2hfqe3ri@codemonkey.org.uk>
References: <20160729150513.GB29545@codemonkey.org.uk>
 <20160729151907.GC29545@codemonkey.org.uk>
 <CAPAsAGxDOvD64+5T4vPiuJgHkdHaaXGRfikFxXGHDRRiW4ivVQ@mail.gmail.com>
 <20160729154929.GA30611@codemonkey.org.uk>
 <579B9339.7030707@gmail.com>
 <579B98B8.40007@gmail.com>
 <20160729183925.GA28376@codemonkey.org.uk>
 <579F2C73.6090406@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <579F2C73.6090406@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Aug 01, 2016 at 02:03:15PM +0300, Andrey Ryabinin wrote:
 > On 07/29/2016 09:39 PM, Dave Jones wrote:
 > > On Fri, Jul 29, 2016 at 08:56:08PM +0300, Andrey Ryabinin wrote:
 > > 
 > >  > >>  > I suspect this is false positives due to changes in KASAN.
 > >  > >>  > Bisection probably will point to
 > >  > >>  > 80a9201a5965f4715d5c09790862e0df84ce0614 ("mm, kasan: switch SLUB to
 > >  > >>  > stackdepot, enable memory quarantine for SLUB)"
 > >  > >>
 > >  > >> good call. reverting that changeset seems to have solved it.
 > >  > > Could you please try with this?
 > >  > Actually, this is not quite right, it should be like this:
 > > 
 > > 
 > > Seems to have stopped the corruption, but now I get NMi watchdog traces..
 > > 
 > 
 > This should help:

Yep, this seems to have silenced all the problems I saw.

thanks,

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
