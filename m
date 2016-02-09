Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 59B7A6B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 09:24:49 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so25619964wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 06:24:49 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id 12si49382476wjy.50.2016.02.09.06.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 06:24:47 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id c200so3738527wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 06:24:47 -0800 (PST)
Date: Tue, 9 Feb 2016 15:24:44 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/3] x86: Honour passed pgprot in track_pfn_insert() and
 track_pfn_remap()
Message-ID: <20160209142444.GA391@gmail.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-2-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWNx=H=u2R+JKM6Dr3oMqeiBSS+hdrYrGT=BJ-JrEyL+w@mail.gmail.com>
 <20160127044036.GR2948@linux.intel.com>
 <CALCETrXJacX8HB3vahu0AaarE98qkx-wW9tRYQ8nVVbHt=FgzQ@mail.gmail.com>
 <20160129144909.GV2948@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160129144909.GV2948@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


* Matthew Wilcox <willy@linux.intel.com> wrote:

> > I sure hope not.  If vm_page_prot was writable, something was already broken, 
> > because this is the vvar mapping, and the vvar mapping is VM_READ (and not 
> > even VM_MAYREAD).
> 
> I do beg yor pardon.  I thought you were inserting a readonly page into the 
> middle of a writable mapping.  Instead you're inserting a non-executable page 
> into the middle of a VM_READ | VM_EXEC mapping. Sorry for the confusion.  I 
> should have written:
> 
> "like your patch ends up mapping the HPET into userspace executable"
> 
> which is far less exciting.

Btw., a side note, an executable HPET page has its own dangers as well, for 
example because it always changes in value, it can probabilistically represent 
'sensible' (and dangerous) executable x86 instructions that exploits can return 
to.

So only mapping it readable (which Andy's patch attempts I think) is worthwile.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
