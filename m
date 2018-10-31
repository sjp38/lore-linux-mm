Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E071D6B0007
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 18:24:45 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s15-v6so15498282iob.11
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 15:24:45 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id d1-v6si13478716ita.120.2018.10.31.15.24.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Oct 2018 15:24:44 -0700 (PDT)
Message-ID: <3da6549832ef68b93b210d5a32b3f12f3565cab0.camel@kernel.crashing.org>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 01 Nov 2018 09:24:29 +1100
In-Reply-To: <877ehyf1cj.fsf@oldenburg.str.redhat.com>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
	 <20181031185032.679e170a@naga.suse.cz>
	 <877ehyf1cj.fsf@oldenburg.str.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Michal =?ISO-8859-1?Q?Such=E1nek?= <msuchanek@suse.de>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Nick Piggin <npiggin@au1.ibm.com>, Anton Blanchard <anton@au1.ibm.com>

On Wed, 2018-10-31 at 18:54 +0100, Florian Weimer wrote:
> 
> It would matter to C code which returns the address of a global variable
> in the main program through and (implicit) int return value.
> 
> The old behavior hid some pointer truncation issues.

Hiding bugs like that is never a good idea..

> > Maybe it would be good idea to generate 64bit relocations on 64bit
> > targets?
> 
> Yes, the Go toolchain definitely needs fixing for PIE.  I don't dispute
> that.

There was never any ABI guarantee that programs would be loaded below
4G... it just *happened*, so that's not per-se an ABI change.

That said, I'm surprised of the choice of address.. I would have rather
moved to above 1TB to benefit from 1T segments...

Nick, Anton, do you know anything about that change ?

Ben.
