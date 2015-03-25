Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD066B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:24:54 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so23038122pac.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:24:53 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id qp10si2875341pbc.10.2015.03.25.02.24.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 02:24:53 -0700 (PDT)
Message-ID: <1427275489.31588.1.camel@ellerman.id.au>
Subject: Re: [PATCH 5/6] mm/gup: Replace ACCESS_ONCE with READ_ONCE for
 STRICT_MM_TYPECHECKS
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 25 Mar 2015 20:24:49 +1100
In-Reply-To: <55127D65.7060605@de.ibm.com>
References: <1427274719-25890-1-git-send-email-mpe@ellerman.id.au>
	 <1427274719-25890-5-git-send-email-mpe@ellerman.id.au>
	 <55127D65.7060605@de.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, aneesh.kumar@in.ibm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, steve.capper@linaro.org, linux-mm@kvack.org, Jason Low <jason.low2@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 2015-03-25 at 10:18 +0100, Christian Borntraeger wrote:
> Am 25.03.2015 um 10:11 schrieb Michael Ellerman:
> > If STRICT_MM_TYPECHECKS is enabled the generic gup code fails to build
> > because we are using ACCESS_ONCE on non-scalar types.
> > 
> > Convert all uses to READ_ONCE.
> 
> There is a similar patch from Jason Low in Andrews patch.

Ah sorry, I didn't think to check.

> If that happens in 4.0-rc, we probably want to merge this before 4.0.

My series can wait, it's not urgent. So I'll plan to merge mine once Andrew's
tree has gone into Linus' tree for 4.1.

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
