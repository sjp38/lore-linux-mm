Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 649846B0038
	for <linux-mm@kvack.org>; Sun, 26 Mar 2017 04:42:18 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id c72so12096605lfh.22
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 01:42:18 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id y27si4338682ljd.267.2017.03.26.01.42.16
        for <linux-mm@kvack.org>;
        Sun, 26 Mar 2017 01:42:17 -0700 (PDT)
Date: Sun, 26 Mar 2017 10:41:50 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: Splat during resume
Message-ID: <20170326084149.pisqkhngxjd65u6g@pd.tnic>
References: <20170325185855.4itsyevunczus7sc@pd.tnic>
 <20170325214615.eqgmkwbkyldt7wwl@pd.tnic>
 <1490516743.17559.7.camel@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1490516743.17559.7.camel@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86-ml <x86@kernel.org>

On Sun, Mar 26, 2017 at 10:25:43AM +0200, Mike Galbraith wrote:
> To be filed under "_maybe_ interesting", my tip-rt tree hits the below
> on boot (survives), ONLY on vaporite (kvm), silicon boots clean, works
> fine, hibernate/suspend gripe free.

Strange - I did boot fine but resume shit in its pants.

> The revert fixed up vaporite.

vaporite, haha, good one. I like that, let's do
s/vaporitization/virtualization/g from now on :-)

Btw, try the 6 patches here: https://marc.info/?l=linux-mm&m=148977696117208&w=2
ontop of tip. Should fix your vaporite too.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
