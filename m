Date: Tue, 8 Jan 2008 14:56:14 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
Message-ID: <20080108135614.GB13019@lazybastard.org>
References: <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <20080108100803.GA24570@wotan.suse.de> <47835FBE.8080406@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <47835FBE.8080406@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 January 2008 12:34:22 +0100, Carsten Otte wrote:
>
> That patch looks very nice. I am going to define PTE_SPECIAL for s390 
> arch next...

"PTE_SPECIAL" does not sound too descriptive.  Maybe PTE_MIXEDMAP?  It
may not be great, but at least it give a hint in the right direction.

JA?rn

-- 
Good warriors cause others to come to them and do not go to others.
-- Sun Tzu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
