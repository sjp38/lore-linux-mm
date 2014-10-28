Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 24428900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 21:20:34 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so6702754pdj.15
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 18:20:33 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id d2si11681356pdi.219.2014.10.27.18.20.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 18:20:33 -0700 (PDT)
Message-ID: <1414459229.31711.0.camel@concordia>
Subject: Re: [PATCH V3 1/2] mm: Update generic gup implementation to handle
 hugepage directory
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 28 Oct 2014 12:20:29 +1100
In-Reply-To: <20141027160612.b7fd0b1cc9d82faeaa674940@linux-foundation.org>
References: 
	<1414233860-7683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20141027160612.b7fd0b1cc9d82faeaa674940@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org

On Mon, 2014-10-27 at 16:06 -0700, Andrew Morton wrote:
> On Sat, 25 Oct 2014 16:14:19 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > Update generic gup implementation with powerpc specific details.
> > On powerpc at pmd level we can have hugepte, normal pmd pointer
> > or a pointer to the hugepage directory.
> 
> I grabbed these.  It would be better if they were merged into the powerpc
> tree where they'll get more testing than in linux-next alone.
 
Fine by me. Can I get an ack from you and/or someone else on CC?

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
