Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 28A7F6B0256
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 06:48:26 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so11533808qkd.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 03:48:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b95si8173759qkh.91.2015.07.24.03.48.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 03:48:25 -0700 (PDT)
Date: Fri, 24 Jul 2015 18:48:15 +0800
From: "dyoung@redhat.com" <dyoung@redhat.com>
Subject: Re: [PATCH mmotm] kexec: arch_kexec_apply_relocations can be static
Message-ID: <20150724104815.GE8405@localhost.localdomain>
References: <201507241644.XJlodOnm%fengguang.wu@intel.com>
 <20150724081102.GA239929@lkp-ib04>
 <20150724101457.GA8405@localhost.localdomain>
 <20150724103048.GA8812@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150724103048.GA8812@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi, Fengguang

On 07/24/15 at 06:30pm, Fengguang Wu wrote:
> Hi Dave,
> 
> On Fri, Jul 24, 2015 at 06:14:57PM +0800, dyoung@redhat.com wrote:
> > Hi, Fengguang
> > 
> > Justs be curious, is this been found by robot script?
> 
> Yes it is. :)
> 
> > On 07/24/15 at 04:11pm, kbuild test robot wrote:
> > > 
> > > Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> > > ---
> > >  kexec_file.c |    2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
> > > index caf47e9..91e9e9d 100644
> > > --- a/kernel/kexec_file.c
> > > +++ b/kernel/kexec_file.c
> > > @@ -122,7 +122,7 @@ arch_kexec_apply_relocations_add(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
> > >  }
> > >  
> > >  /* Apply relocations of type REL */
> > > -int __weak
> > > +static int __weak
> > >  arch_kexec_apply_relocations(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
> > >  			     unsigned int relsec)
> > >  {
> > 
> > It is a weak function, why move it to static? There's also several other similar
> > functions in the file.
> 
> Sorry we have detection logic for the weak symbols. However here it
> failed to work due to line wrapping. I'll fix it up.

No problem, thanks for explanation, nice work for the automation scripts..

Dave 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
