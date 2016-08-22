Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 822656B0038
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:23:35 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id x131so6059451ite.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 12:23:35 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id r205si18059177itc.37.2016.08.22.12.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 12:23:24 -0700 (PDT)
Date: Mon, 22 Aug 2016 13:22:56 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4] powerpc: Do not make the entire heap executable
Message-ID: <20160822192256.GA10199@obsidianresearch.com>
References: <20160810130030.5268-1-dvlasenk@redhat.com>
 <874m6ejf81.fsf@linux.vnet.ibm.com>
 <47a2e87e-5299-a009-8a65-5171b33967a1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47a2e87e-5299-a009-8a65-5171b33967a1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <dvlasenk@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Kees Cook <keescook@chromium.org>, Oleg Nesterov <oleg@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 22, 2016 at 08:37:05PM +0200, Denys Vlasenko wrote:

> >Is this going to break any application ? I am asking because you
> >mentioned the patch is lightly tested.
> 
> I booted powerpc64 machine with RHEL7 installation,
> it did not catch fire.

When I authored the original patch my concern was if it had unforseen
impacts on other platforms. I know PPC32 and ARM32 work OK.

It would good to test other platforms as well.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
