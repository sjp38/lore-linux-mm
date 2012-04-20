Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 7B9A46B00E7
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:30:55 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1763835pbc.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 12:30:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120420191418.GA3569@merkur.ravnborg.org>
References: <20120417155502.GE22687@tiehlicka.suse.cz>
	<20120420182907.GG32324@google.com>
	<20120420191418.GA3569@merkur.ravnborg.org>
Date: Fri, 20 Apr 2012 12:30:54 -0700
Message-ID: <CAE9FiQU-M0yW_rwysq56zrZzift=PxgwioMmx8bMcJ5o20m2TQ@mail.gmail.com>
Subject: Re: Weirdness in __alloc_bootmem_node_high
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 20, 2012 at 12:14 PM, Sam Ravnborg <sam@ravnborg.org> wrote:
>
> I took a quick look at this.
> __alloc_bootmem_node_high() is used in mm/sparse.c - but only
> if SPARSEMEM_VMEMMAP is enabled.
>
> mips has this:
>
> config ARCH_SPARSEMEM_ENABLE
> =A0 =A0 =A0 =A0bool
> =A0 =A0 =A0 =A0select SPARSEMEM_STATIC
>
> So SPARSEMEM_VMEMMAP is not enabled.
>
> __alloc_bootmem_node_high() is used in mm/sparse-vmemmap.c which
> also depends on CONFIG_SPARSEMEM_VMEMMAP.
>
>
> So I really do not see the logic in __alloc_bootmem_node_high()
> being used anymore and it can be replaced by __alloc_bootmem_node()

Yes, you are right. __alloc_bootmem_node_high could be removed.

BTW, x86 is still the only one that use NO_BOOTMEM.

Are you working on making sparc to use NO_BOOTMEM?

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
