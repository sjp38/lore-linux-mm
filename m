Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72E886B0003
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 15:55:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c85so5257897pfb.12
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 12:55:58 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id u19si4875213pfn.213.2018.04.13.12.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 12:55:56 -0700 (PDT)
Date: Fri, 13 Apr 2018 13:55:51 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 00/32] docs/vm: convert to ReST format
Message-ID: <20180413135551.0e6d1b12@lwn.net>
In-Reply-To: <20180401063857.GA3357@rapoport-lnx>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
	<20180329154607.3d8bda75@lwn.net>
	<20180401063857.GA3357@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Sorry for the silence, I'm pedaling as fast as I can, honest...

On Sun, 1 Apr 2018 09:38:58 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> My thinking was to start with mechanical RST conversion and then to start
> working on the contents and ordering of the documentation. Some of the
> existing files, e.g. ksm.txt, can be moved as is into the appropriate
> places, others, like transhuge.txt should be at least split into admin/user
> and developer guides.
> 
> Another problem with many of the existing mm docs is that they are rather
> developer notes and it wouldn't be really straight forward to assign them
> to a particular topic.

All this sounds good.

> I believe that keeping the mm docs together will give better visibility of
> what (little) mm documentation we have and will make the updates easier.
> The documents that fit well into a certain topic could be linked there. For
> instance:

...but this sounds like just the opposite...?  

I've had this conversation with folks in a number of subsystems.
Everybody wants to keep their documentation together in one place - it's
easier for the developers after all.  But for the readers I think it's
objectively worse.  It perpetuates the mess that Documentation/ is, and
forces readers to go digging through all kinds of inappropriate material
in the hope of finding something that tells them what they need to know.

So I would *really* like to split the documentation by audience, as has
been done for a number of other kernel subsystems (and eventually all, I
hope).

I can go ahead and apply the RST conversion, that seems like a step in
the right direction regardless.  But I sure hope we don't really have to
keep it as an unorganized jumble of stuff...

Thanks,

jon
