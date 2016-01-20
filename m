Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBE46B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 00:27:46 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id e65so188625928pfe.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 21:27:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yq2si12587968pac.19.2016.01.19.21.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 21:27:45 -0800 (PST)
Date: Tue, 19 Jan 2016 21:27:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
Message-Id: <20160119212745.eee310f5.akpm@linux-foundation.org>
In-Reply-To: <CAAHN_R2CFYsSSU_Qr-_cE+9-=OqDOa88annh9uA1TymuJncL8A@mail.gmail.com>
References: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
	<20160119141430.8ff9c464.akpm@linux-foundation.org>
	<CAAHN_R2CFYsSSU_Qr-_cE+9-=OqDOa88annh9uA1TymuJncL8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Wed, 20 Jan 2016 08:47:39 +0530 Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com> wrote:

> On 20 January 2016 at 03:44, Andrew Morton <akpm@linux-foundation.org> wrote:
> > Any thoughts on the obvious back-compatibility concerns?  ie, why did
> > Siddhesh implement this in the first place?  My bad for not ensuring
> > that the changelog told us this.
> >
> > https://lkml.org/lkml/2012/1/14/25 has more info:
> >
> > : Memory mmaped by glibc for a thread stack currently shows up as a
> > : simple anonymous map, which makes it difficult to differentiate between
> > : memory usage of the thread on stack and other dynamic allocation.
> > : Since glibc already uses MAP_STACK to request this mapping, the
> > : attached patch uses this flag to add additional VM_STACK_FLAGS to the
> > : resulting vma so that the mapping is treated as a stack and not any
> > : regular anonymous mapping.  Also, one may use vm_flags to decide if a
> > : vma is a stack.
> >
> > But even that doesn't really tell us what the actual *value* of the
> > patch is to end-users.
> 
> The end users needed a way to identify thread stacks programmatically
> and there wasn't a way to do that.  I'm afraid I no longer remember
> (or have access to the resources that would aid my memory since I
> changed employers) the details of their requirement.  However, I did
> do this on my own time because I thought it was an interesting project
> for me and nobody really gave any feedback then as to its utility, so
> as far as I am concerned you could roll back the main thread maps
> information since the information is available in the thread-specific
> files.

OK, thanks.  I was thinking of queueing this for 4.6 to let it bake in
-next for a cycle, but quadratic performance is bad and nobody will
test such an obscure feature in -next so maybe I'll jam it into 4.5 and we
wait and see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
