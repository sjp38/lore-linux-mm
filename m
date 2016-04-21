Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91C9D6B028F
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 02:36:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so130781470pfe.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:36:08 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id pt18si1781766pab.194.2016.04.20.23.36.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 23:36:07 -0700 (PDT)
Message-ID: <1461220562.3245.3.camel@ellerman.id.au>
Subject: Re: [PATCH] powerpc/mm: Always use STRICT_MM_TYPECHECKS
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 21 Apr 2016 16:36:02 +1000
In-Reply-To: <571853FA.5080901@gmail.com>
References: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
	 <571853FA.5080901@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linuxppc-dev@ozlabs.org
Cc: Paul Mackerras <paulus@samba.org>, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org

On Thu, 2016-04-21 at 14:15 +1000, Balbir Singh wrote:
> 
> On 21/04/16 13:37, Michael Ellerman wrote:

> > Testing done by Paul Mackerras has shown that with a modern compiler
> > there is no negative effect on code generation from enabling
> > STRICT_MM_TYPECHECKS.
> > 
> > So remove the option, and always use the strict type definitions.
> > 
> 
> Should we wait for Aneesh's patches before merging this in.

Preferably not.

I've already rebased his patches on top of this, it's trivial, it's just
removing code.

It also makes some things we might want to do as part of his series easier
(like adding a raw accessor to get the __be64 pmd/pte val).

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
