Message-ID: <47838E00.3090900@de.ibm.com>
Date: Tue, 08 Jan 2008 15:51:44 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
References: <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <20080108100803.GA24570@wotan.suse.de> <47835FBE.8080406@de.ibm.com> <20080108135614.GB13019@lazybastard.org>
In-Reply-To: <20080108135614.GB13019@lazybastard.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?UTF-8?B?SsO2cm4gRW5nZWw=?= <joern@logfs.org>
Cc: Nick Piggin <npiggin@suse.de>, carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

JA?rn Engel wrote:
> "PTE_SPECIAL" does not sound too descriptive.  Maybe PTE_MIXEDMAP?  It
> may not be great, but at least it give a hint in the right direction.
True, I've chosen a different name. PTE_SPECIAL is the name in  Nick's 
original patch (see patch in this thread).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
