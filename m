Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id BD55A6B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 17:06:15 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id uy5so8532978obc.1
        for <linux-mm@kvack.org>; Mon, 26 May 2014 14:06:15 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id o4si21128764obi.87.2014.05.26.14.06.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 May 2014 14:06:15 -0700 (PDT)
Message-ID: <1401138312.12982.6.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm/process_vm_access: move into ipc/
From: Davidlohr Bueso <davidlohr@hp.com>
In-Reply-To: <alpine.LSU.2.11.1405261210140.3411@eggly.anvils>
References: <20140524135925.32597.45754.stgit@zurg>
	 <alpine.LSU.2.11.1405261210140.3411@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 26 May 2014 14:05:12 -0700
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Mon, 2014-05-26 at 12:16 -0700, Hugh Dickins wrote:
> On Sat, 24 May 2014, Konstantin Khlebnikov wrote:
> 
> > "CROSS_MEMORY_ATTACH" and mm/process_vm_access.c seems misnamed and misplaced.
> > Actually it's a kind of IPC and it has no more relation to MM than sys_read().
> > This patch moves code into ipc/ and config option into init/Kconfig.
> > 
> > Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> 
> I disagree, and SysV's ipc/ isn't where I would expect to find it.
> How about we just leave it where it is in mm?

Agreed, the ipc directory is only for sysv and posix IPC, mm is much
more suitable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
