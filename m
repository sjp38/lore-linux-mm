Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 133D16B0387
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 11:23:52 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n127so145263567qkf.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 08:23:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x72si569529qka.141.2017.03.03.08.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 08:23:51 -0800 (PST)
Date: Fri, 3 Mar 2017 17:23:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: use-after-free in zap_page_range
Message-ID: <20170303162348.GD7496@redhat.com>
References: <CACT4Y+YQscOM_H-gZqyzd7n79nUA3QM8=UsX55QEyoapn4QqdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YQscOM_H-gZqyzd7n79nUA3QM8=UsX55QEyoapn4QqdA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

Hello Dmitry,

On Fri, Mar 03, 2017 at 02:54:26PM +0100, Dmitry Vyukov wrote:
> The following program triggers use-after-free in zap_page_range:
> https://gist.githubusercontent.com/dvyukov/b59dfbaa0cb1e5231094d228fa57c9bd/raw/95c4da18cb96f8aaa47c10012d8c4484fd5917ad/gistfile1.txt

I posted the fix for this one yesterday (found while doing more code
reviews of the upstream code searching for any other potential issue):

https://www.spinics.net/lists/linux-mm/msg122905.html
https://www.spinics.net/lists/linux-mm/msg122903.html

Could you test with those two applied on top of the others updates
that are already in -mm?

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
