Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 791C96B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 00:33:42 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id u14so4625649lbd.12
        for <linux-mm@kvack.org>; Sun, 08 Sep 2013 21:33:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <522C8DA8.6030701@oracle.com>
References: <522C8DA8.6030701@oracle.com>
Date: Mon, 9 Sep 2013 12:33:40 +0800
Message-ID: <CAJd=RBAd6-kX127cdTs10Ty7LJ+cGQX8NvX9H1bb4QSh4erzLw@mail.gmail.com>
Subject: Re: hugetlb: NULL ptr deref in region_truncate
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, trinity@vger.kernel.org

On Sun, Sep 8, 2013 at 10:46 PM, Sasha Levin <sasha.levin@oracle.com> wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest, running latest -next
> kernel, I've
> stumbled on the following:
>
> [  998.281867] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000274
> [  998.283333] IP: [<ffffffff812707c4>] region_truncate+0x64/0xd0
> [  998.284288] PGD 0
> [  998.284717] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  998.286506] Modules linked in:
> [  998.287101] CPU: 88 PID: 24650 Comm: trinity-child85 Tainted: G    B   W
> 3.11.0-next-20130906-sasha #3985

 *  'B' - System has hit bad_page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
