Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A84326B034D
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 12:30:42 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e19-v6so7672017qtq.1
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 09:30:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r34-v6si497912qtb.257.2018.10.28.09.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Oct 2018 09:30:41 -0700 (PDT)
Message-ID: <14e021f1976700540d05287ca70f5a0834760f4e.camel@redhat.com>
Subject: Re: [Linux-c6x-dev] [PATCH RESEND] c6x: switch to NO_BOOTMEM
From: Mark Salter <msalter@redhat.com>
Date: Sun, 28 Oct 2018 12:30:38 -0400
In-Reply-To: <6ff7ce1b549ad4a17ebb5d8221edaac57518fca4.camel@redhat.com>
References: <20181027092028.GC6770@rapoport-lnx>
	 <6ff7ce1b549ad4a17ebb5d8221edaac57518fca4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-c6x-dev@linux-c6x.org

On Sat, 2018-10-27 at 13:20 -0400, Mark Salter wrote:
> On Sat, 2018-10-27 at 10:20 +0100, Mike Rapoport wrote:
> > Hi,
> > 
> > The patch below that switches c6x to NO_BOOTMEM is already merged into c6x
> > tree, but as there were no pull request from c6x during v4.19 merge window
> > it is still not present in Linus' tree.
> > 
> > Probably it would be better to direct it via mm tree to avoid possible
> > conflicts and breakage because of bootmem removal.
> > 
> 
> I had to refresh the patch due to conflict with
> 
> commit be7cd2df1d22d29e5f23ce8744fc465cc07cc2bc
> Author: Rob Herring <robh@kernel.org>
> Date:   Wed Aug 1 15:00:12 2018 -0600
> 
>     c6x: use common built-in dtb support
> 
> The updated patch is in the c6x tree:
> 
> git://linux-c6x.org/git/projects/linux-c6x-upstreaming.git
> commit fe381767b94fc53d3db700ba1d55928a4b5bc6c8

Oops, forgot to add my s-o-b. It's now:

commit 4d8106f0299c7942c5f13a22da6d553d28127ef5
Author: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date:   Mon Jun 25 12:02:34 2018 +0300

    c6x: switch to NO_BOOTMEM
