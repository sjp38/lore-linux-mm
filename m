Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id DA7056B0070
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 05:28:45 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so334128pbb.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 02:28:45 -0700 (PDT)
Date: Fri, 19 Oct 2012 02:28:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.7 v3] mm, mempolicy: hold task->mempolicy refcount
 while reading numa_maps.
In-Reply-To: <508110C4.6030805@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1210190227240.26815@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <20121017181413.GA16805@redhat.com> <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com> <20121017193229.GC16805@redhat.com>
 <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com> <20121017194501.GA24400@redhat.com> <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com> <alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com> <507F803A.8000900@jp.fujitsu.com>
 <507F86BD.7070201@jp.fujitsu.com> <alpine.DEB.2.00.1210181255470.26994@chino.kir.corp.google.com> <508110C4.6030805@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 19 Oct 2012, Kamezawa Hiroyuki wrote:

> From c5849c9034abeec3f26bf30dadccd393b0c5c25e Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 19 Oct 2012 17:00:55 +0900
> Subject: [PATCH] hold task->mempolicy while numa_maps scans.
> 
>  /proc/<pid>/numa_maps scans vma and show mempolicy under
>  mmap_sem. It sometimes accesses task->mempolicy which can
>  be freed without mmap_sem and numa_maps can show some
>  garbage while scanning.
> 
> This patch tries to take reference count of task->mempolicy at reading
> numa_maps before calling get_vma_policy(). By this, task->mempolicy
> will not be freed until numa_maps reaches its end.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good, but the patch is whitespace damaged so it doesn't apply.  When 
that's fixed:

Acked-by: David Rientjes <rientjes@google.com>

Thanks for following through on this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
