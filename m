Date: Tue, 8 Jan 2008 23:12:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
Message-ID: <20080108221246.GA25832@wotan.suse.de>
References: <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <20080108100803.GA24570@wotan.suse.de> <47835FBE.8080406@de.ibm.com> <20080108135614.GB13019@lazybastard.org> <47838E00.3090900@de.ibm.com> <6934efce0801081009v793715aal217ead6749a103aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6934efce0801081009v793715aal217ead6749a103aa@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: carsteno@de.ibm.com, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 08, 2008 at 10:09:52AM -0800, Jared Hulbert wrote:
> > Jorn Engel wrote:
> > > "PTE_SPECIAL" does not sound too descriptive.  Maybe PTE_MIXEDMAP?  It
> > > may not be great, but at least it give a hint in the right direction.
> > True, I've chosen a different name. PTE_SPECIAL is the name in  Nick's
> > original patch (see patch in this thread).
> 
> Nick also want's to use that bit to "implement my lockless
> get_user_page" I assume that's why the name is a little vague.

Yeah, and to simplify vm_normal_page on those architectures which provide it.
So it isn't just for VM_MIXEDMAP mappings (unless you're implementing a bit
specifically for that as an s390 specific thing -- which is reasonable for now).

We have 2 types of user mappings in the VM; "normal" and not-normal. I don't think
the latter have a name, so I call them special. If you're used to "normal" then
I think special is descriptive enough ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
