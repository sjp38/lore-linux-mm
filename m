Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3642F6B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 20:56:40 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id v4-v6so605829plp.16
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:56:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k80sor412217pfh.102.2018.03.13.17.56.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 17:56:39 -0700 (PDT)
Date: Wed, 14 Mar 2018 10:56:20 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: OK to merge via powerpc? (was Re: [PATCH 05/14] mm: make
 memblock_alloc_base_nid non-static)
Message-ID: <20180314105620.5d98ff9f@roar.ozlabs.ibm.com>
In-Reply-To: <20180313124128.875efd39a5d3ce9a9bb37e63@linux-foundation.org>
References: <20180213150824.27689-1-npiggin@gmail.com>
	<20180213150824.27689-6-npiggin@gmail.com>
	<873714goxg.fsf@concordia.ellerman.id.au>
	<20180313124128.875efd39a5d3ce9a9bb37e63@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, mhocko@suse.com, catalin.marinas@arm.com, pasha.tatashin@oracle.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, baiyaowei@cmss.chinamobile.com, bob.picco@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, 13 Mar 2018 12:41:28 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 13 Mar 2018 23:06:35 +1100 Michael Ellerman <mpe@ellerman.id.au> wrote:
> 
> > Anyone object to us merging the following patch via the powerpc tree?
> > 
> > Full series is here if anyone's interested:
> >   http://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=28377&state=*
> >   
> 
> Yup, please go ahead.
> 
> I assume the change to the memblock_alloc_range() declaration was an
> unrelated, unchangelogged cleanup.
> 

It is. I'm trying to get better at that. Michael might drop that bit if
he's not already sick of fixing up my patches...

Thanks,
Nick
