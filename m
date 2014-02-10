Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id AF38C6B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 20:49:27 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id vb8so6543555obc.4
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 17:49:27 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id eo3si226350oeb.65.2014.02.09.17.49.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Feb 2014 17:49:26 -0800 (PST)
Message-ID: <52F82E62.2010709@oracle.com>
Date: Sun, 09 Feb 2014 20:41:54 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shm: hang in shmem_fallocate
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1402081841160.26825@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 02/08/2014 10:25 PM, Hugh Dickins wrote:
 > Would trinity be likely to have a thread or process repeatedly faulting
 > in pages from the hole while it is being punched?

I can see how trinity would do that, but just to be certain - Cc davej.

On 02/08/2014 10:25 PM, Hugh Dickins wrote:
 > Does this happen with other holepunch filesystems?  If it does not,
 > I'd suppose it's because the tmpfs fault-in-newly-created-page path
 > is lighter than a consistent disk-based filesystem's has to be.
 > But we don't want to make the tmpfs path heavier to match them.

No, this is strictly limited to tmpfs, and AFAIK trinity tests hole
punching in other filesystems and I make sure to get a bunch of those
mounted before starting testing.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
