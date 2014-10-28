Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E1EB7900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 21:32:25 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lf10so4929843pab.5
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 18:32:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ra9si11763505pac.136.2014.10.27.18.32.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 18:32:24 -0700 (PDT)
Date: Mon, 27 Oct 2014 18:32:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 1/2] mm: Update generic gup implementation to handle
 hugepage directory
Message-Id: <20141027183241.a5339085.akpm@linux-foundation.org>
In-Reply-To: <1414459229.31711.0.camel@concordia>
References: <1414233860-7683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20141027160612.b7fd0b1cc9d82faeaa674940@linux-foundation.org>
	<1414459229.31711.0.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org

On Tue, 28 Oct 2014 12:20:29 +1100 Michael Ellerman <mpe@ellerman.id.au> wrote:

> On Mon, 2014-10-27 at 16:06 -0700, Andrew Morton wrote:
> > On Sat, 25 Oct 2014 16:14:19 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > 
> > > Update generic gup implementation with powerpc specific details.
> > > On powerpc at pmd level we can have hugepte, normal pmd pointer
> > > or a pointer to the hugepage directory.
> > 
> > I grabbed these.  It would be better if they were merged into the powerpc
> > tree where they'll get more testing than in linux-next alone.
>  
> Fine by me. Can I get an ack from you and/or someone else on CC?
> 

Only arm and arm64 use this code.  Steve, could you please look it over
and check that arm is still happy?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
