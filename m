Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 419E78E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 20:06:37 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 13-v6so13727859oiq.1
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 17:06:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9-v6sor19326794ota.203.2018.09.21.17.06.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 17:06:36 -0700 (PDT)
MIME-Version: 1.0
References: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180917161245.c4bb8546d2c6069b0506c5dd@linux-foundation.org>
 <CAGXu5jLRuWOMPTfXAFFiVSb6CUKaa_TD4gncef+MT84pcazW6w@mail.gmail.com> <AT5PR8401MB1169D656C8B5E121752FC0F8AB120@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
In-Reply-To: <AT5PR8401MB1169D656C8B5E121752FC0F8AB120@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 21 Sep 2018 17:06:24 -0700
Message-ID: <CAPcyv4iuRkQWsWa-YfTMDJUTUr1QouEsS6zD_LAjcpbLGXCPEQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm: Randomize free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <MHocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hpe.com>

On Fri, Sep 21, 2018 at 4:51 PM Elliott, Robert (Persistent Memory)
<elliott@hpe.com> wrote:
>
>
> > -----Original Message-----
> > From: linux-kernel-owner@vger.kernel.org <linux-kernel-
> > owner@vger.kernel.org> On Behalf Of Kees Cook
> > Sent: Friday, September 21, 2018 2:13 PM
> > Subject: Re: [PATCH 0/3] mm: Randomize free memory
> ...
> > I'd be curious to hear more about the mentioned cache performance
> > improvements. I love it when a security feature actually _improves_
> > performance. :)
>
> It's been a problem in the HPC space:
> http://www.nersc.gov/research-and-development/knl-cache-mode-performance-coe/
>
> A kernel module called zonesort is available to try to help:
> https://software.intel.com/en-us/articles/xeon-phi-software
>
> and this abandoned patch series proposed that for the kernel:
> https://lkml.org/lkml/2017/8/23/195
>
> Dan's patch series doesn't attempt to ensure buffers won't conflict, but
> also reduces the chance that the buffers will. This will make performance
> more consistent, albeit slower than "optimal" (which is near impossible
> to attain in a general-purpose kernel).  That's better than forcing
> users to deploy remedies like:
>     "To eliminate this gradual degradation, we have added a Stream
>      measurement to the Node Health Check that follows each job;
>      nodes are rebooted whenever their measured memory bandwidth
>      falls below 300 GB/s."

Robert, thanks for that! Yes, instead of run-to-run variations
alternating between almost-never-conflict and nearly-always-conflict,
we'll get a random / average distribution of cache conflicts.
