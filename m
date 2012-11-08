Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 9CEDE6B002B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 17:09:39 -0500 (EST)
Date: Thu, 8 Nov 2012 14:09:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Add a test program for variable page sizes in
 mmap/shmget v2
Message-Id: <20121108140938.357228e0.akpm@linux-foundation.org>
In-Reply-To: <20121108220150.GA2726@tassilo.jf.intel.com>
References: <1352408486-4318-1-git-send-email-andi@firstfloor.org>
	<20121108132946.c2b9e8b7.akpm@linux-foundation.org>
	<20121108220150.GA2726@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Dave Young <dyoung@redhat.com>

On Thu, 8 Nov 2012 14:01:50 -0800
Andi Kleen <ak@linux.intel.com> wrote:

> On Thu, Nov 08, 2012 at 01:29:46PM -0800, Andrew Morton wrote:
> > On Thu,  8 Nov 2012 13:01:26 -0800
> > Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > From: Andi Kleen <ak@linux.intel.com>
> > > 
> > > Not hooked up to the harness so far, because it usually needs
> > > special boot options for 1GB pages.
> > 
> > This isn't the case from my reading: we *can* hook it up now?
> 
> Yes, but also need to set the sysctls.

That doesn't sound terribly involved?

> > > index b336b24..7300d07 100644
> > > --- a/tools/testing/selftests/vm/Makefile
> > > +++ b/tools/testing/selftests/vm/Makefile
> > > @@ -1,9 +1,9 @@
> > >  # Makefile for vm selftests
> > >  
> > >  CC = $(CROSS_COMPILE)gcc
> > > -CFLAGS = -Wall -Wextra
> > > +CFLAGS = -Wall
> > 
> > Why this?  It doesn't change anything with my gcc so I think
> > I'll revert that.
> 
> There were lots of warnings with signed/unsigned comparisons on my gcc
> (4.6) and since I personally consider those useless I just disabled
> the warning.

eh, OK, I'll update the changelog.

> > 
> > I just tried a `make run_vmtests' and it fell on its face. 
> > There's a little comment in there saying "please run as root", but we
> > don't *want* that.  The selftests should be runnable as non-root and
> > should, where unavoidable, emit a warning and proceed if elevated
> > permissions are required.
> 
> My test requires root. That is only the ipc test requires root.
> To be honest I have no idea why but I don't claim to understand
> why ipcperms() does all the weird stuff it does.
> 
> 
> > 
> > I tried running it as root and my workstation hung, requiring a reboot.
> > Won't be doing that again.
> 
> My test system didn't hang FWIW.

It wasn't thuge-gen which hung.  It happened really early in
run_vmtests, perhaps setting nr_hugepages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
