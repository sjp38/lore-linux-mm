Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 221996B03C1
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 07:52:07 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id g43so47824293uah.2
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 04:52:07 -0800 (PST)
Received: from mail-vk0-x233.google.com (mail-vk0-x233.google.com. [2607:f8b0:400c:c05::233])
        by mx.google.com with ESMTPS id r32si1380248uar.142.2017.03.08.04.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 04:52:06 -0800 (PST)
Received: by mail-vk0-x233.google.com with SMTP id t8so8673946vke.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 04:52:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170303162348.GD7496@redhat.com>
References: <CACT4Y+YQscOM_H-gZqyzd7n79nUA3QM8=UsX55QEyoapn4QqdA@mail.gmail.com>
 <20170303162348.GD7496@redhat.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 8 Mar 2017 13:51:45 +0100
Message-ID: <CACT4Y+ZzkZ0xQRmqZLBMHs2h169uffiXD17b-UaK_vwL6vZGtw@mail.gmail.com>
Subject: Re: mm: use-after-free in zap_page_range
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Fri, Mar 3, 2017 at 5:23 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hello Dmitry,
>
> On Fri, Mar 03, 2017 at 02:54:26PM +0100, Dmitry Vyukov wrote:
>> The following program triggers use-after-free in zap_page_range:
>> https://gist.githubusercontent.com/dvyukov/b59dfbaa0cb1e5231094d228fa57c9bd/raw/95c4da18cb96f8aaa47c10012d8c4484fd5917ad/gistfile1.txt
>
> I posted the fix for this one yesterday (found while doing more code
> reviews of the upstream code searching for any other potential issue):
>
> https://www.spinics.net/lists/linux-mm/msg122905.html
> https://www.spinics.net/lists/linux-mm/msg122903.html
>
> Could you test with those two applied on top of the others updates
> that are already in -mm?

This is already in mmotm/auto-latest, so we are testing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
