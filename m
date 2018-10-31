Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 309516B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 18:41:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b34-v6so11533160ede.5
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 15:41:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8-v6si5387ejg.304.2018.10.31.15.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 15:41:42 -0700 (PDT)
Date: Wed, 31 Oct 2018 23:41:40 +0100
From: Michal =?UTF-8?B?U3VjaMOhbmVr?= <msuchanek@suse.de>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
Message-ID: <20181031234140.70021082@naga.suse.cz>
In-Reply-To: <87bm79n57l.fsf@linux.ibm.com>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
	<20181031185032.679e170a@naga.suse.cz>
	<877ehyf1cj.fsf@oldenburg.str.redhat.com>
	<87efc5n73a.fsf@linux.ibm.com>
	<87in1hlsa7.fsf@oldenburg.str.redhat.com>
	<87bm79n57l.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tulio Magno Quites Machado Filho <tuliom@ascii.art.br>
Cc: Florian Weimer <fweimer@redhat.com>, "Lynn A. Boger" <laboger@linux.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Wed, 31 Oct 2018 19:04:14 -0300
Tulio Magno Quites Machado Filho <tuliom@ascii.art.br> wrote:

> Florian Weimer <fweimer@redhat.com> writes:
> 
> > * Tulio Magno Quites Machado Filho:
> >  
> >> I wonder if this is restricted to linker that Golang uses.
> >> Were you able to reproduce the same problem with Binutils'
> >> linker?  
> >
> > The example is carefully constructed to use the external linker.  It
> > invokes gcc, which then invokes the BFD linker in my case.  
> 
> Indeed. That question was unnecessary.  :-D
> 
> > Based on the relocations, I assume there is only so much the linker
> > can do here.  I'm amazed that it produces an executable at all, let
> > alone one that runs correctly on some kernel versions!  
> 
> Agreed.  That isn't expected to work.  Both the compiler and the
> linker have to generate PIE for it to work.
> 
> > I assume that the Go toolchain simply lacks PIE support on
> > ppc64le.  
> 
> Maybe the support is there, but it doesn't generate PIC by default?
> 
golang has -fPIC IIRC. It does not benefit from the GNU toolchian
synergy of always calling the linker with the correct flags
corresponding to the generated code, though. So when gcc flips the
switch default value golang happily produces incompatible objects.

Also I suspect some pieces of stdlib are not compiled with the flags
you pass in for the build so there are always some objects somewhere
that are not compatible.

Thanks

Michal
