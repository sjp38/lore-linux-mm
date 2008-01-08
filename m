Received: by wa-out-1112.google.com with SMTP id m33so12843022wag.8
        for <linux-mm@kvack.org>; Tue, 08 Jan 2008 10:09:53 -0800 (PST)
Message-ID: <6934efce0801081009v793715aal217ead6749a103aa@mail.gmail.com>
Date: Tue, 8 Jan 2008 10:09:52 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
In-Reply-To: <47838E00.3090900@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <476A73F0.4070704@de.ibm.com> <476B9000.2090707@de.ibm.com>
	 <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com>
	 <20071221104701.GE28484@wotan.suse.de>
	 <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
	 <20080108100803.GA24570@wotan.suse.de> <47835FBE.8080406@de.ibm.com>
	 <20080108135614.GB13019@lazybastard.org> <47838E00.3090900@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

> Jorn Engel wrote:
> > "PTE_SPECIAL" does not sound too descriptive.  Maybe PTE_MIXEDMAP?  It
> > may not be great, but at least it give a hint in the right direction.
> True, I've chosen a different name. PTE_SPECIAL is the name in  Nick's
> original patch (see patch in this thread).

Nick also want's to use that bit to "implement my lockless
get_user_page" I assume that's why the name is a little vague.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
