Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2931E6B02C5
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 05:56:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so38889259wme.1
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 02:56:29 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.75])
        by mx.google.com with ESMTPS id r4si2147281wjw.190.2016.04.21.02.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 02:56:28 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] powerpc/mm: Always use STRICT_MM_TYPECHECKS
Date: Thu, 21 Apr 2016 11:56:21 +0200
Message-ID: <4231376.YDJ7xlGR0L@wuerfel>
In-Reply-To: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
References: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, aneesh.kumar@linux.vnet.ibm.com

On Thursday 21 April 2016 13:37:59 Michael Ellerman wrote:
> Testing done by Paul Mackerras has shown that with a modern compiler
> there is no negative effect on code generation from enabling
> STRICT_MM_TYPECHECKS.
> 
> So remove the option, and always use the strict type definitions.
> 
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> 

I recently ran into the same thing on ARM and have checked the history
on the symbol. It seems that some architectures cannot pass structures
in registers as function arguments, but powerpc can, so it was never
needed in the first place.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
