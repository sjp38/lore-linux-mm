Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4F56B0007
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 15:41:31 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p128so276977pga.19
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 12:41:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 99-v6si619061plc.601.2018.03.13.12.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 12:41:30 -0700 (PDT)
Date: Tue, 13 Mar 2018 12:41:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: OK to merge via powerpc? (was Re: [PATCH 05/14] mm: make
 memblock_alloc_base_nid non-static)
Message-Id: <20180313124128.875efd39a5d3ce9a9bb37e63@linux-foundation.org>
In-Reply-To: <873714goxg.fsf@concordia.ellerman.id.au>
References: <20180213150824.27689-1-npiggin@gmail.com>
	<20180213150824.27689-6-npiggin@gmail.com>
	<873714goxg.fsf@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: mhocko@suse.com, catalin.marinas@arm.com, pasha.tatashin@oracle.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, npiggin@gmail.com, baiyaowei@cmss.chinamobile.com, bob.picco@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, 13 Mar 2018 23:06:35 +1100 Michael Ellerman <mpe@ellerman.id.au> wrote:

> Anyone object to us merging the following patch via the powerpc tree?
> 
> Full series is here if anyone's interested:
>   http://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=28377&state=*
> 

Yup, please go ahead.

I assume the change to the memblock_alloc_range() declaration was an
unrelated, unchangelogged cleanup.
