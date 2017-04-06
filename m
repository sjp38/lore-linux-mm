Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC9D6B042E
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 10:05:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p22so11930106qka.4
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 07:05:12 -0700 (PDT)
Received: from cmta18.telus.net (cmta18.telus.net. [209.171.16.91])
        by mx.google.com with ESMTPS id k188si1453817qkd.87.2017.04.06.07.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 07:05:11 -0700 (PDT)
From: "Doug Smythies" <dsmythies@telus.net>
References: <003401d2a750$19f98190$4dec84b0$@net> <20170327233617.353obb3m4wz7n5kv@node.shutemov.name> <alpine.LSU.2.11.1703280008020.2599@eggly.anvils> upRmczQN0LrIFupSgckp7c
In-Reply-To: upRmczQN0LrIFupSgckp7c
Subject: RE: ksmd lockup - kernel 4.11-rc series
Date: Thu, 6 Apr 2017 07:05:05 -0700
Message-ID: <000801d2aede$cc414cd0$64c3e670$@net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: en-ca
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hugh Dickins' <hughd@google.com>, "'Kirill A. Shutemov'" <kirill@shutemov.name>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

Hi,

Thank you for your quick work on this.

On 2017.04.02 17:03 Hugh Dickins wrote:
> On Tue, 28 Mar 2017, Hugh Dickins wrote:
>> On Tue, 28 Mar 2017, Kirill A. Shutemov wrote:
>>> On Mon, Mar 27, 2017 at 04:16:00PM -0700, Doug Smythies wrote:

...[snip]...

> Worked out what it was yesterday, but my first patch failed overnight:
> I'd missed the placement of the next_pte label.  It had a similar fix
> to mm/migrate.c in it, that hit me too in testing; but this morning I
> find Naoya's 4b0ece6fa016 in git, which fixes that.

I think I got that one sometimes also.

>  Same issue here.
>
> [PATCH] mm: fix page_vma_mapped_walk() for ksm pages

... [snip] ...

To establish a baseline, I ran kernel 4.11-rc5 without this
patch for 24 hours. The failure occurred twice.

I have been running the exact same scenario with the patch
for 55 hours now without any issues.

Note: I stayed with version 1 of the patch, even though there
was a version 2 sent out on Monday.

... Doug


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
