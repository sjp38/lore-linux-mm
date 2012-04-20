Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id A7D076B00E7
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:32:39 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1765759pbc.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 12:32:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120420192937.GE15021@tiehlicka.suse.cz>
References: <20120417155502.GE22687@tiehlicka.suse.cz>
	<20120420182907.GG32324@google.com>
	<20120420191418.GA3569@merkur.ravnborg.org>
	<20120420192937.GE15021@tiehlicka.suse.cz>
Date: Fri, 20 Apr 2012 12:32:38 -0700
Message-ID: <CAE9FiQUytfCvr8c++im+DignUwZvHmnu8gPNDG6SOJzrF_FsNg@mail.gmail.com>
Subject: Re: Weirdness in __alloc_bootmem_node_high
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Sam Ravnborg <sam@ravnborg.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 20, 2012 at 12:29 PM, Michal Hocko <mhocko@suse.cz> wrote:
> This is what I can see in the current (Linus) git:
> ./arch/sparc/Kconfig: =A0 select SPARSEMEM_VMEMMAP_ENABLE
> ./arch/powerpc/Kconfig: select SPARSEMEM_VMEMMAP_ENABLE
> ./arch/ia64/Kconfig: =A0 =A0select SPARSEMEM_VMEMMAP_ENABLE
> ./arch/s390/Kconfig: =A0 =A0select SPARSEMEM_VMEMMAP_ENABLE
> ./arch/s390/Kconfig: =A0 =A0select SPARSEMEM_VMEMMAP
> ./arch/x86/Kconfig: =A0 =A0 select SPARSEMEM_VMEMMAP_ENABLE if X86_64
>
> So there are more arches which enable SPARSEMEM_VMEMMAP so the function
> is used. Or am I missing something?

MAX_DMA32_PFN is not defined for them.

I was think only x86 have that define. Actually mips have that defined too.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
