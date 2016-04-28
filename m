Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2216B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:27:35 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id fn8so144804963igb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 22:27:35 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id r7si14571513igg.18.2016.04.27.22.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 22:27:34 -0700 (PDT)
Message-ID: <1461821251.25861.4.camel@ellerman.id.au>
Subject: Re: [PATCH] powerpc/mm: Always use STRICT_MM_TYPECHECKS
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 28 Apr 2016 15:27:31 +1000
In-Reply-To: <4231376.YDJ7xlGR0L@wuerfel>
References: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
	 <4231376.YDJ7xlGR0L@wuerfel>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, aneesh.kumar@linux.vnet.ibm.com

On Thu, 2016-04-21 at 11:56 +0200, Arnd Bergmann wrote:
> On Thursday 21 April 2016 13:37:59 Michael Ellerman wrote:
> > Testing done by Paul Mackerras has shown that with a modern compiler
> > there is no negative effect on code generation from enabling
> > STRICT_MM_TYPECHECKS.
> > 
> > So remove the option, and always use the strict type definitions.
> > 
> > Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> > 
> 
> I recently ran into the same thing on ARM and have checked the history
> on the symbol. It seems that some architectures cannot pass structures
> in registers as function arguments, but powerpc can, so it was never
> needed in the first place.

Thanks Arnd.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
