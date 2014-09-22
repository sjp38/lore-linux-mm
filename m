Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 512DA6B0038
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 13:04:09 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id t60so3241191wes.23
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 10:04:08 -0700 (PDT)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id gr6si9817999wib.44.2014.09.22.10.04.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 10:04:07 -0700 (PDT)
Date: Mon, 22 Sep 2014 10:03:46 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH] mm: Support compiling out madvise and fadvise
Message-ID: <20140922170345.GD25352@thin>
References: <20140922161109.GA25027@thin>
 <1411404460.28679.12.camel@linux-t7sj.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411404460.28679.12.camel@linux-t7sj.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 22, 2014 at 06:47:40PM +0200, Davidlohr Bueso wrote:
> On Mon, 2014-09-22 at 09:11 -0700, Josh Triplett wrote:
> > Many embedded systems will not need these syscalls, and omitting them
> > saves space.  Add a new EXPERT config option CONFIG_ADVISE_SYSCALLS
> > (default y) to support compiling them out.
> 
> general question: if a user chooses CONFIG_ADVISE_SYSCALLS=n (or any
> config option related to tinyfication) and breaks the system/workload...
> will that be acceptable for a kernel pov? In other words, what's the
> degree of responsibility the user will have when choosing such builds?

It's hidden behind EXPERT for exactly that reason: if you turn it off,
and your userspace needs it and can't cope with ENOSYS, you get to keep
all the pieces.  Only turn it off if you know your userspace doesn't
use it.

The same thing goes for several other such options, such as UID16,
SYSCTL_SYSCALL, SGETMASK_SYSCALL, and USELIB.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
