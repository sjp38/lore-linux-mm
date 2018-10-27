Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77EA96B033A
	for <linux-mm@kvack.org>; Sat, 27 Oct 2018 13:20:40 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id m63-v6so5026466qkb.9
        for <linux-mm@kvack.org>; Sat, 27 Oct 2018 10:20:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k19si5684590qvg.219.2018.10.27.10.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Oct 2018 10:20:39 -0700 (PDT)
Message-ID: <6ff7ce1b549ad4a17ebb5d8221edaac57518fca4.camel@redhat.com>
Subject: Re: [PATCH RESEND] c6x: switch to NO_BOOTMEM
From: Mark Salter <msalter@redhat.com>
Date: Sat, 27 Oct 2018 13:20:37 -0400
In-Reply-To: <20181027092028.GC6770@rapoport-lnx>
References: <20181027092028.GC6770@rapoport-lnx>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-c6x-dev@linux-c6x.org, linux-mm@kvack.org

On Sat, 2018-10-27 at 10:20 +0100, Mike Rapoport wrote:
> Hi,
> 
> The patch below that switches c6x to NO_BOOTMEM is already merged into c6x
> tree, but as there were no pull request from c6x during v4.19 merge window
> it is still not present in Linus' tree.
> 
> Probably it would be better to direct it via mm tree to avoid possible
> conflicts and breakage because of bootmem removal.
> 

I had to refresh the patch due to conflict with

commit be7cd2df1d22d29e5f23ce8744fc465cc07cc2bc
Author: Rob Herring <robh@kernel.org>
Date:   Wed Aug 1 15:00:12 2018 -0600

    c6x: use common built-in dtb support

The updated patch is in the c6x tree:

git://linux-c6x.org/git/projects/linux-c6x-upstreaming.git
commit fe381767b94fc53d3db700ba1d55928a4b5bc6c8
