Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1436B0035
	for <linux-mm@kvack.org>; Sat, 13 Sep 2014 05:25:31 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id w62so1791840wes.26
        for <linux-mm@kvack.org>; Sat, 13 Sep 2014 02:25:30 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id j6si7059040wia.48.2014.09.13.02.25.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 13 Sep 2014 02:25:30 -0700 (PDT)
Date: Sat, 13 Sep 2014 11:25:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 00/10] Intel MPX support
In-Reply-To: <54136459.1070700@intel.com>
Message-ID: <alpine.DEB.2.10.1409131121570.23397@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <54124379.5090502@intel.com> <alpine.DEB.2.10.1409121543090.4178@nanos> <54136459.1070700@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Sep 2014, Dave Hansen wrote:

> On 09/12/2014 12:21 PM, Thomas Gleixner wrote:
> > Yes, the most important question is WHY must the kernel handle the
> > bound table memory allocation in the first place. The "documentation"
> > patch completely fails to tell that.
> 
> This will become the description of "patch 04/10".  Feel free to wait

Thanks for writing this up! That helps a lot.

> until we repost these to read it, but I'm posting it here because it's
> going to be a couple of days before we actually get a new set of patches
> out.
> 
> Any suggestions for how much of this is appropriate for Documentation/
> would be much appreciated.  I don't have a good feel for it.

I think all of it. The kernels problem is definitely not that it
drains in documentation :)
 
> Having ruled out all of the userspace-only approaches for managing
> bounds tables that we could think of, we create them on demand
> in the kernel.

So what the documentation wants on top of this is the rule set which
describes the expected behaviour of sane applications and perhaps the
potential consequences for insane ones. Not that people care about
that much, but at least we can point them to documentation if they
come up with their weird ass "bug" reports :)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
