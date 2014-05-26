Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id DC2BD6B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 15:53:44 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so505204wib.11
        for <linux-mm@kvack.org>; Mon, 26 May 2014 12:53:44 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id qa3si1925063wic.33.2014.05.26.12.53.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 May 2014 12:53:43 -0700 (PDT)
Date: Mon, 26 May 2014 20:53:41 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm/process_vm_access: move into ipc/
Message-ID: <20140526195341.GQ18016@ZenIV.linux.org.uk>
References: <20140524135925.32597.45754.stgit@zurg>
 <alpine.LSU.2.11.1405261210140.3411@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1405261210140.3411@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 26, 2014 at 12:16:20PM -0700, Hugh Dickins wrote:
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

Anything playing with get_user_pages(tsk, ...) with tsk != current is very
much a part of VM guts.

While we are at it, do_generic_file_read() *is* in mm/filemap.c.  And signals
and pipes are also "a kind of IPC", so the rationale is really weak.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
