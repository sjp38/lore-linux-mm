Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1F20A6B0256
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 06:31:37 -0400 (EDT)
Received: by ietj16 with SMTP id j16so15272806iet.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 03:31:37 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hu6si1697499igb.44.2015.07.24.03.31.36
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 03:31:36 -0700 (PDT)
Date: Fri, 24 Jul 2015 18:30:48 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH mmotm] kexec: arch_kexec_apply_relocations can be static
Message-ID: <20150724103048.GA8812@wfg-t540p.sh.intel.com>
References: <201507241644.XJlodOnm%fengguang.wu@intel.com>
 <20150724081102.GA239929@lkp-ib04>
 <20150724101457.GA8405@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150724101457.GA8405@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dyoung@redhat.com" <dyoung@redhat.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Dave,

On Fri, Jul 24, 2015 at 06:14:57PM +0800, dyoung@redhat.com wrote:
> Hi, Fengguang
> 
> Justs be curious, is this been found by robot script?

Yes it is. :)

> On 07/24/15 at 04:11pm, kbuild test robot wrote:
> > 
> > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> > ---
> >  kexec_file.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
> > index caf47e9..91e9e9d 100644
> > --- a/kernel/kexec_file.c
> > +++ b/kernel/kexec_file.c
> > @@ -122,7 +122,7 @@ arch_kexec_apply_relocations_add(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
> >  }
> >  
> >  /* Apply relocations of type REL */
> > -int __weak
> > +static int __weak
> >  arch_kexec_apply_relocations(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
> >  			     unsigned int relsec)
> >  {
> 
> It is a weak function, why move it to static? There's also several other similar
> functions in the file.

Sorry we have detection logic for the weak symbols. However here it
failed to work due to line wrapping. I'll fix it up.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
