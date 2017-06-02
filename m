Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 008006B0292
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 10:34:02 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d68so69538280ita.13
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 07:34:01 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id p14si854972ioi.54.2017.06.02.07.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 07:34:00 -0700 (PDT)
Date: Fri, 2 Jun 2017 09:33:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.LSU.2.11.1706012045240.4854@eggly.anvils>
Message-ID: <alpine.DEB.2.20.1706020932350.28919@east.gentwo.org>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils> <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org>
 <alpine.LSU.2.11.1706011002130.3014@eggly.anvils> <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org> <alpine.LSU.2.11.1706011128490.3622@eggly.anvils> <878tlb2igt.fsf@concordia.ellerman.id.au> <alpine.LSU.2.11.1706012045240.4854@eggly.anvils>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 1 Jun 2017, Hugh Dickins wrote:

> SLUB versus SLAB, cpu versus memory?  Since someone has taken the
> trouble to write it with ctors in the past, I didn't feel on firm
> enough ground to recommend such a change.  But it may be obvious
> to someone else that your suggestion would be better (or worse).

Umm how about using alloc_pages() for pageframes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
