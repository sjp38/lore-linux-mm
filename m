Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 37FFF82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 17:11:31 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so32786205pac.3
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 14:11:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yp1si31889189pbc.152.2015.10.16.14.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 14:11:30 -0700 (PDT)
Date: Fri, 16 Oct 2015 14:11:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] mm/powerpc: enabling memory soft dirty tracking
Message-Id: <20151016141129.8b014c6d882c475fafe577a9@linux-foundation.org>
In-Reply-To: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulus@samba.org, criu@openvz.org

On Fri, 16 Oct 2015 14:07:05 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> This series is enabling the software memory dirty tracking in the
> kernel for powerpc.  This is the follow up of the commit 0f8975ec4db2
> ("mm: soft-dirty bits for user memory changes tracking") which
> introduced this feature in the mm code.
> 
> The first patch is fixing an issue in the code clearing the soft dirty
> bit.  The PTE were not cleared before being modified, leading to hang
> on ppc64.
> 
> The second patch is fixing a build issue when the transparent huge
> page is not enabled.
> 
> The third patch is introducing the soft dirty tracking in the powerpc
> architecture code. 

I grabbed these patches, but they're more a ppc thing than a core
kernel thing.  I can merge them into 4.3 with suitable acks or drop
them if they turn up in the powerpc tree.  Or something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
