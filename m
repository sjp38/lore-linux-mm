Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE3B6B0292
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 10:32:20 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d14so27189965qkb.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 07:32:20 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id q5si22963115qkb.137.2017.06.02.07.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 07:32:19 -0700 (PDT)
Date: Fri, 2 Jun 2017 09:32:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.LSU.2.11.1706011128490.3622@eggly.anvils>
Message-ID: <alpine.DEB.2.20.1706020931080.28919@east.gentwo.org>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils> <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org>
 <alpine.LSU.2.11.1706011002130.3014@eggly.anvils> <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org> <alpine.LSU.2.11.1706011128490.3622@eggly.anvils>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 1 Jun 2017, Hugh Dickins wrote:

> Thanks a lot for working that out.  Makes sense, fully understood now,
> nothing to worry about (though makes one wonder whether it's efficient
> to use ctors on high-alignment caches; or whether an internal "zero-me"
> ctor would be useful).

Use kzalloc to zero it. And here is another example of using slab
allocations for page frames. Use the page allocator for this? The page
allocator is there for allocating page frames. The slab allocator main
purpose is to allocate small objects....


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
