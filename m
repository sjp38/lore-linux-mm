Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3803B6B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 04:31:47 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id h7so68480539wjy.6
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 01:31:47 -0800 (PST)
Received: from mail-wj0-x242.google.com (mail-wj0-x242.google.com. [2a00:1450:400c:c01::242])
        by mx.google.com with ESMTPS id g206si16522066wmf.103.2017.01.31.01.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 01:31:44 -0800 (PST)
Received: by mail-wj0-x242.google.com with SMTP id kq3so10008392wjc.3
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 01:31:44 -0800 (PST)
Date: Tue, 31 Jan 2017 12:31:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: sleeping function called from invalid context
 shmem_undo_range
Message-ID: <20170131093141.GA15899@node.shutemov.name>
References: <CACT4Y+Y+mAg82iUD4gMA_DPoEBzjA3uO=kVki1x9NCJRQKwhHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Y+mAg82iUD4gMA_DPoEBzjA3uO=kVki1x9NCJRQKwhHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Tue, Jan 31, 2017 at 09:27:41AM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I've got the following report while running syzkaller fuzzer on
> fd694aaa46c7ed811b72eb47d5eb11ce7ab3f7f1:

This should help:
