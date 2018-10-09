Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84C106B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 19:24:43 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r67-v6so3131295pfd.21
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 16:24:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y1-v6si20292340pgf.78.2018.10.09.16.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 16:24:42 -0700 (PDT)
Date: Tue, 9 Oct 2018 16:24:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG -next 20181008] list corruption with
 "mm/slub: remove useless condition in deactivate_slab"
Message-Id: <20181009162440.d40400a42544aced64f28572@linux-foundation.org>
In-Reply-To: <20181009063500.GB3555@osiris>
References: <20181009063500.GB3555@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Pingfan Liu <kernelfans@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, 9 Oct 2018 08:35:00 +0200 Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> with linux-next for 20181008 I can reliably crash my system with lot's of
> debugging options enabled on s390. List debugging triggers the list
> corruption below, which I could bisect down to this commit:
> 
> fde06e07750477f049f12d7d471ffa505338a3e7 is the first bad commit
> commit fde06e07750477f049f12d7d471ffa505338a3e7
> Author: Pingfan Liu <kernelfans@gmail.com>
> Date:   Thu Oct 4 07:43:01 2018 +1000
> 
>     mm/slub: remove useless condition in deactivate_slab
> 
>     The var l should be used to reflect the original list, on which the page
>     should be.  But c->page is not on any list.  Furthermore, the current code
>     does not update the value of l.  Hence remove the related logic
> 
>     Link: http://lkml.kernel.org/r/1537941430-16217-1-git-send-email-kernelfans@gmail.com
>     Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
>     Acked-by: Christoph Lameter <cl@linux.com>
>     Cc: Pekka Enberg <penberg@kernel.org>
>     Cc: David Rientjes <rientjes@google.com>
>     Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> 
> list_add double add: new=000003d1029ecc08, prev=000000008ff846d0,next=000003d1029ecc08.
> ------------[ cut here ]------------
> kernel BUG at lib/list_debug.c:31!

Thanks much.  I'll drop
mm-slub-remove-useless-condition-in-deactivate_slab.patch.
