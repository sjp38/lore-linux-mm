Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBB5E6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 21:38:03 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id m12so9757897wrm.1
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 18:38:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w102sor452744wrb.45.2018.01.15.18.38.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 18:38:02 -0800 (PST)
Date: Tue, 16 Jan 2018 03:37:59 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [REGRESSION] testing/selftests/x86/ pkeys build failures
Message-ID: <20180116023759.4xpgkc53qfbtmemb@gmail.com>
References: <360ef254-48bc-aee6-70f9-858f773b8693@redhat.com>
 <20180112125537.bdl376ziiaqp664o@gmail.com>
 <063ba398-88e6-8650-2905-c378ee1fb8b2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <063ba398-88e6-8650-2905-c378ee1fb8b2@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, x86@kernel.org, Dave Hansen <dave.hansen@intel.com>, Ram Pai <linuxram@us.ibm.com>


* Florian Weimer <fweimer@redhat.com> wrote:

> On 01/12/2018 01:55 PM, Ingo Molnar wrote:
> > 
> > * Florian Weimer <fweimer@redhat.com> wrote:
> > 
> > > This patch is based on the previous discussion (pkeys: Support setting
> > > access rights for signal handlers):
> > > 
> > >    https://marc.info/?t=151285426000001
> > > 
> > > It aligns the signal semantics of the x86 implementation with the upcoming
> > > POWER implementation, and defines a new flag, so that applications can
> > > detect which semantics the kernel uses.
> > > 
> > > A change in this area is needed to make memory protection keys usable for
> > > protecting the GOT in the dynamic linker.
> > > 
> > > (Feel free to replace the trigraphs in the commit message before committing,
> > > or to remove the program altogether.)
> > 
> > Could you please send patches not as MIME attachments?
> 
> My mail infrastructure corrupts patches not sent as attachments, sorry.

Your headers suggest the following mail client:

  User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
        Thunderbird/52.5.0

Have you seen the suggestions in Documentation/process/email-clients.rst, which 
lists a handful of Thunderbird tips:

  Thunderbird (GUI)
  *****************

  Thunderbird is an Outlook clone that likes to mangle text, but there are ways
  to coerce it into behaving.

?

> > Also, the protection keys testcase first need to be fixed, before we complicate
> > them - for example on a pretty regular Ubuntu x86-64 installation they fail to
> > build with the build errors attached further below.
> 
> I can fix things up so that they build on Fedora 26, Debian stretch, and Red
> Hat Enterprise Linux 7.  Would that be sufficient?

Yeah, I think so.

> Fedora 23 is out of support and I'd prefer not invest any work into it.
> 
> Note that I find it strange to make this a precondition for even looking at
> the patch.

I wanted to try the patch to give review feedback, but found these annoyances. 
It's customary to make new features dependent on the cleanliness of the underlying 
code.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
