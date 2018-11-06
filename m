Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9596B02C0
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 01:26:08 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id f5-v6so893765ljj.17
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 22:26:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g88-v6sor26646590lji.0.2018.11.05.22.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 22:26:06 -0800 (PST)
MIME-Version: 1.0
References: <20181103050504.GA3049@jordon-HP-15-Notebook-PC>
 <20181103120235.GA10491@bombadil.infradead.org> <20181104083611.GB7829@rapoport-lnx>
 <CAFqt6zaVUT0RGpz+jE4c7rb5prOtDhnxOy-NAiFM9G6jMwofVg@mail.gmail.com>
 <20181105091302.GA3713@rapoport-lnx> <CAFqt6zYbb9xpnOhhoESq3BbF4aD0_UKzh=MrwJ-i+NiUqNh7+Q@mail.gmail.com>
 <20181106062133.GB4499@rapoport-lnx>
In-Reply-To: <20181106062133.GB4499@rapoport-lnx>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 6 Nov 2018 11:59:27 +0530
Message-ID: <CAFqt6zYEB5=rpo6sGZW3Regwd9F7T0+Y_UpjQVBndR_-DYaHZA@mail.gmail.com>
Subject: Re: [PATCH] mm: Create the new vm_fault_t type
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.ibm.com
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, riel@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, Nov 6, 2018 at 11:51 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Mon, Nov 05, 2018 at 07:23:55PM +0530, Souptick Joarder wrote:
> > On Mon, Nov 5, 2018 at 2:43 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > >
> > > On Mon, Nov 05, 2018 at 11:14:17AM +0530, Souptick Joarder wrote:
> > > > Hi Matthew,
> > > >
> > > > On Sun, Nov 4, 2018 at 2:06 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > > > >
> > > > > On Sat, Nov 03, 2018 at 05:02:36AM -0700, Matthew Wilcox wrote:
> > > > > > On Sat, Nov 03, 2018 at 10:35:04AM +0530, Souptick Joarder wrote:
>
> > > > > > > +typedef __bitwise unsigned int vm_fault_t;
> > > > > > > +
> > > > > > > +/**
> > > > > > > + * enum - VM_FAULT code
> > > > > >
> > > > > > Can you document an anonymous enum?  I've never tried.  Did you run this
> > > > > > through 'make htmldocs'?
> > > > >
> > > > > You cannot document an anonymous enum.
> > > >
> > > > I assume, you are pointing to Document folder and I don't know if this
> > > > enum need to be documented or not.
> > >
> > > The enum should be documented, even if it's documentation is (yet) not
> > > linked anywhere in the Documentation/
> > >
> > > > I didn't run 'make htmldocs' as there is no document related changes.
> > >
> > > You can verify that kernel-doc can parse your documentation by running
> > >
> > > scripts/kernel-doc -none -v <filename>
> >
> > I run "scripts/kernel-doc -none -v include/linux/mm_types.h" and it is showing
> > below error and warning which is linked to enum in discussion.
> >
> > include/linux/mm_types.h:612: info: Scanning doc for typedef vm_fault_t
> > include/linux/mm_types.h:623: info: Scanning doc for enum
> > include/linux/mm_types.h:628: warning: contents before sections
> > include/linux/mm_types.h:660: error: Cannot parse enum!
> > 1 errors
> > 1 warnings
> >
> > Shall I keep the documentation for enum or remove it from this patch ?
>
> The documentation should be there, you just need to add a name for the
> enum. Then kernel-doc will be able to parse it.
>
> > > > >
> > > > > > > + * This enum is used to track the VM_FAULT code return by page
> > > > > > > + * fault handlers.
> > > > > >
>
> I think that the enum description should also include the text from the
> comment that described VM_FAULT_* defines:
>
> /*
>  * Different kinds of faults, as returned by handle_mm_fault().
>  * Used to decide whether a process gets delivered SIGBUS or
>  * just gets major/minor fault counters bumped up.
>  */
>

Ok, will add  both in v2. Thanks.
