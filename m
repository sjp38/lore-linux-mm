Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B55A18E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:38:45 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id d63so1375784iog.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:38:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor1331810ioh.73.2019.01.14.23.38.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 23:38:44 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-7-git-send-email-kernelfans@gmail.com> <fff8c6b6-7344-7ecb-b1a8-3c49af34c892@intel.com>
In-Reply-To: <fff8c6b6-7344-7ecb-b1a8-3c49af34c892@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 15:38:33 +0800
Message-ID: <CAFgQCTsZOeBb8dUaq5LLfwzTObK5tT47h5U_BkfgtPDYLW9CqA@mail.gmail.com>
Subject: Re: [PATCHv2 6/7] x86/mm: remove bottom-up allocation style for x86_64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 15, 2019 at 7:27 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/10/19 9:12 PM, Pingfan Liu wrote:
> > Although kaslr-kernel can avoid to stain the movable node. [1]
>
> Can you explain what staining is, or perhaps try to use some more
> standard nomenclature?  There are exactly 0 instances of the word
> "stain" in arch/x86/ or mm/.
>
I mean that KASLR may randomly choose some positions for base address,
which are located in movable node.

> > But the
> > pgtable can still stain the movable node. That is a probability problem,
> > although low, but exist. This patch tries to make it certainty by
> > allocating pgtable on unmovable node, instead of following kernel end.
>
> Anyway, can you read my suggested summary in the earlier patch and see
> if it fits or if I missed anything?  This description is really hard to
> read.
>
Your summary in the reply to [PATCH 0/7] express the things clearly. I
will use them to update the commit log

> ...> +#ifdef CONFIG_X86_32
> > +
> > +static unsigned long min_pfn_mapped;
> > +
> >  static unsigned long __init get_new_step_size(unsigned long step_size)
> >  {
> >       /*
> > @@ -653,6 +655,32 @@ static void __init memory_map_bottom_up(unsigned long map_start,
> >       }
> >  }
> >
> > +static unsigned long __init init_range_memory_mapping32(
> > +     unsigned long r_start, unsigned long r_end)
> > +{
>
> Why is this returning a value which is not used?
>
> Did you compile this?  Didn't you get a warning that you're not
> returning a value from a function returning non-void?
>
It should be void. I will fix it in next version

> Also, I'd much rather see something like this written:
>
> static __init
> unsigned long init_range_memory_mapping32(unsigned long r_start,
>                                           unsigned long r_end)
>
> than what you have above.  But, if you get rid of the 'unsigned long',
> it will look much more sane in the first place.

Yes. Thank for your kindly review.

Best Regards,
Pingfan
