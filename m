Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C8178900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 00:46:56 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id rd3so2356005pab.13
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 21:46:56 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id v7si191913pdn.28.2014.10.28.21.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 21:46:55 -0700 (PDT)
Message-ID: <1414558008.7417.2.camel@concordia>
Subject: Re: [PATCH V3 1/2] mm: Update generic gup implementation to handle
 hugepage directory
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 29 Oct 2014 15:46:48 +1100
In-Reply-To: <20141028104451.GB4187@linaro.org>
References: 
	<1414233860-7683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20141027160612.b7fd0b1cc9d82faeaa674940@linux-foundation.org>
	 <1414459229.31711.0.camel@concordia>
	 <20141027183241.a5339085.akpm@linux-foundation.org>
	 <20141028104451.GB4187@linaro.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org

On Tue, 2014-10-28 at 10:44 +0000, Steve Capper wrote:
> On Mon, Oct 27, 2014 at 06:32:41PM -0700, Andrew Morton wrote:
> > On Tue, 28 Oct 2014 12:20:29 +1100 Michael Ellerman <mpe@ellerman.id.au> wrote:
> > 
> > > On Mon, 2014-10-27 at 16:06 -0700, Andrew Morton wrote:
> > > > On Sat, 25 Oct 2014 16:14:19 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > Update generic gup implementation with powerpc specific details.
> > > > > On powerpc at pmd level we can have hugepte, normal pmd pointer
> > > > > or a pointer to the hugepage directory.
> > > > 
> > > > I grabbed these.  It would be better if they were merged into the powerpc
> > > > tree where they'll get more testing than in linux-next alone.
> > >  
> > > Fine by me. Can I get an ack from you and/or someone else on CC?
> > 
> > Only arm and arm64 use this code.  Steve, could you please look it over
> > and check that arm is still happy?
> 
> Hi Andrew,
> I've tested it and posted some comments on it.
> 
> If the arch/arm and arch/arm64 changes are removed and a comment about
> an assumption made by the new gup_huge_pte code is added then I'm happy.

OK thanks Steve.

Aneesh can you do those changes and resend and I'll put it in powerpc next.

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
