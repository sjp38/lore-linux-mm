Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFFBE8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 17:08:38 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so24359514pfq.8
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 14:08:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d71sor4779755pga.73.2018.12.28.14.08.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 14:08:37 -0800 (PST)
Date: Sat, 29 Dec 2018 01:08:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: KASAN: use-after-free Read in filemap_fault
Message-ID: <20181228220833.rinbqizv7h5myxds@kshutemo-mobl1>
References: <000000000000b57d19057e1b383d@google.com>
 <20181228220152.wkeslziuovnunvwk@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181228220152.wkeslziuovnunvwk@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, darrick.wong@oracle.com, hannes@cmpxchg.org, hughd@google.com, jack@suse.cz, josef@toxicpanda.com, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, willy@infradead.org

On Sat, Dec 29, 2018 at 01:01:52AM +0300, Kirill A. Shutemov wrote:
> On Fri, Dec 28, 2018 at 12:51:04PM -0800, syzbot wrote:
> > Allocated by task 8196:
> 
> ...
> 
> > Freed by task 8197:
> 
> Hm. VMA allocated by one process (I don't see threads in the test case)
> gets freed by another one. Looks fishy to me.

Ignore this. I need some to go sleep %)

-- 
 Kirill A. Shutemov
