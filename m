Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0AF6B0255
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:35:50 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id cy9so41062083pac.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 04:35:50 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ym10si2020326pab.146.2016.01.29.04.35.49
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 04:35:49 -0800 (PST)
Date: Fri, 29 Jan 2016 15:35:44 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: mm: another VM_BUG_ON_PAGE(PageTail(page))
Message-ID: <20160129123544.GB146512@black.fi.intel.com>
References: <CACT4Y+Z9UDZNLsoEz-DO3fX_+0gTwPUA=uE++J=w1sAG_4CGJg@mail.gmail.com>
 <20160128105136.GD2396@node.shutemov.name>
 <CACT4Y+ZZkWTuw8hxnqLEf81bF=GL2SKv8Buqwv3qByBeSLBf+A@mail.gmail.com>
 <20160128114042.GE2396@node.shutemov.name>
 <CACT4Y+Ybn_YAsP6f_wRfPr-zw2ZbF8cfKBMtqhZ=ya-qCpeq3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Ybn_YAsP6f_wRfPr-zw2ZbF8cfKBMtqhZ=ya-qCpeq3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Doug Gilbert <dgilbert@interlog.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Shiraz Hashim <shashim@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, linux-scsi <linux-scsi@vger.kernel.org>

