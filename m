Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6DA8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:28:32 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id r65so1323485iod.12
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:28:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v192sor3949259itb.17.2019.01.14.23.28.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 23:28:31 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-3-git-send-email-kernelfans@gmail.com> <a5fe4d86-3551-7da8-caca-fdd497ace99f@intel.com>
In-Reply-To: <a5fe4d86-3551-7da8-caca-fdd497ace99f@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 15:28:19 +0800
Message-ID: <CAFgQCTsMo9+8m9jxUK5Eax44rsY+a3TBpb4HsUrScJW3OQ18Kw@mail.gmail.com>
Subject: Re: [PATCHv2 2/7] acpi: change the topo of acpi_table_upgrade()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 15, 2019 at 7:12 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/10/19 9:12 PM, Pingfan Liu wrote:
> > The current acpi_table_upgrade() relies on initrd_start, but this var is
>
> "var" meaning variable?
>
> Could you please go back and try to ensure you spell out all the words
> you are intending to write?  I think "topo" probably means "topology",
> but it's a really odd word to use for changing the arguments of a
> function, so I'm not sure.
>
> There are a couple more of these in this set.
>
Yes. I will do it and fix them in next version.

> > only valid after relocate_initrd(). There is requirement to extract the
> > acpi info from initrd before memblock-allocator can work(see [2/4]), hence
> > acpi_table_upgrade() need to accept the input param directly.
>
> "[2/4]"
>
> It looks like you quickly resent this set without updating the patch
> descriptions.
>
> > diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
> > index 61203ee..84e0a79 100644
> > --- a/drivers/acpi/tables.c
> > +++ b/drivers/acpi/tables.c
> > @@ -471,10 +471,8 @@ static DECLARE_BITMAP(acpi_initrd_installed, NR_ACPI_INITRD_TABLES);
> >
> >  #define MAP_CHUNK_SIZE   (NR_FIX_BTMAPS << PAGE_SHIFT)
> >
> > -void __init acpi_table_upgrade(void)
> > +void __init acpi_table_upgrade(void *data, size_t size)
> >  {
> > -     void *data = (void *)initrd_start;
> > -     size_t size = initrd_end - initrd_start;
> >       int sig, no, table_nr = 0, total_offset = 0;
> >       long offset = 0;
> >       struct acpi_table_header *table;
>
> I know you are just replacing some existing variables, but we have a
> slightly higher standard for naming when you actually have to specify
> arguments to a function.  Can you please give these proper names?
>
OK, I will change it to acpi_table_upgrade(void *initrd, size_t size).

Thanks,
Pingfan
