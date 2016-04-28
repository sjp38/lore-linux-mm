Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 736F86B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:13:27 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id fn8so144280638igb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 22:13:27 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id o5si25598671igv.48.2016.04.27.22.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 22:13:26 -0700 (PDT)
Date: Thu, 28 Apr 2016 15:13:19 +1000
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH] powerpc/mm: Always use STRICT_MM_TYPECHECKS
Message-ID: <20160428051319.GA3591@oak.ozlabs.ibm.com>
References: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@ozlabs.org, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org

On Thu, Apr 21, 2016 at 01:37:59PM +1000, Michael Ellerman wrote:
> Testing done by Paul Mackerras has shown that with a modern compiler
> there is no negative effect on code generation from enabling
> STRICT_MM_TYPECHECKS.
> 
> So remove the option, and always use the strict type definitions.
> 
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>

Acked-by: Paul Mackerras <paulus@ozlabs.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
