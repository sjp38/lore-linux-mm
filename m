Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5E73D6B0311
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 11:35:52 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id j62so14463143uaj.12
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:35:52 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id q43si9582757uaf.71.2017.06.01.08.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 08:35:51 -0700 (PDT)
Date: Thu, 1 Jun 2017 10:31:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.LSU.2.11.1705311112290.1839@eggly.anvils>
Message-ID: <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



> > I am curious as to what is going on there. Do you have the output from
> > these failed allocations?
>
> I thought the relevant output was in my mail.  I did skip the Mem-Info
> dump, since that just seemed noise in this case: we know memory can get
> fragmented.  What more output are you looking for?

The output for the failing allocations when you disabling debugging. For
that I would think that you need remove(!) the slub_debug statement on the kernel
command line. You can verify that debug is off by inspecting the values in
/sys/kernel/slab/<yourcache>/<debug option>

> But it was still order 4 when booted with slub_debug=O, which surprised me.
> And that surprises you too?  If so, then we ought to dig into it further.

No it does no longer. I dont think slub_debug=O does disable debugging
(frankly I am not sure what it does). Please do not specify any debug options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
