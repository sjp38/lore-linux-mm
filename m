Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03B6E8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:53:48 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id z5-v6so885230ljb.13
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:53:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor17262709lfi.3.2019.01.08.03.53.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 03:53:46 -0800 (PST)
MIME-Version: 1.0
References: <20181106120544.GA3783@jordon-HP-15-Notebook-PC>
 <20181115014737.GA2353@rapoport-lnx> <CAFqt6zbOgSm9omt+6iV0GJtZdZ_qyTr9Jte9ZGYRQ1M4CdB-mA@mail.gmail.com>
 <CAFqt6zZ67tFA8FjFZ4xM+YUAez9EdPHinx0ky0X5sQHyZ9nkLg@mail.gmail.com>
 <CAFqt6zYY=xfqvVxRi1spbMNzvoM_CYNxbm6d7_79a5bBHxUzuA@mail.gmail.com> <20190107144411.b3e2313649f106de0776432e@linux-foundation.org>
In-Reply-To: <20190107144411.b3e2313649f106de0776432e@linux-foundation.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 8 Jan 2019 17:23:33 +0530
Message-ID: <CAFqt6zZV-9qJYbKDbCNR1AkmeCVFWrJ2i270=w0i3jNEnN_nvw@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Create the new vm_fault_t type
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rppt@linux.ibm.com, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, riel@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, Jan 8, 2019 at 4:14 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 7 Jan 2019 11:47:12 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> > > Do I need to make any further improvement for this patch ?
> >
> > If no further comment, can we get this patch in queue for 5.0-rcX ?
>
> I stopped paying attention a while ago, sorry.
>
> Please resend everything which you believe is ready to go.

Sure, I will resend. no prob :)
