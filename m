Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD0466B0007
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 17:46:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v17so5463470pff.9
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 14:46:10 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id 19si5226298pfi.285.2018.03.29.14.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 14:46:09 -0700 (PDT)
Date: Thu, 29 Mar 2018 15:46:07 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 00/32] docs/vm: convert to ReST format
Message-ID: <20180329154607.3d8bda75@lwn.net>
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Mar 2018 21:22:16 +0200
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> These patches convert files in Documentation/vm to ReST format, add an
> initial index and link it to the top level documentation.
> 
> There are no contents changes in the documentation, except few spelling
> fixes. The relatively large diffstat stems from the indentation and
> paragraph wrapping changes.
> 
> I've tried to keep the formatting as consistent as possible, but I could
> miss some places that needed markup and add some markup where it was not
> necessary.

So I've been pondering on these for a bit.  It looks like a reasonable and
straightforward RST conversion, no real complaints there.  But I do have a
couple of concerns...

One is that, as we move documentation into RST, I'm really trying to
organize it a bit so that it is better tuned to the various audiences we
have.  For example, ksm.txt is going to be of interest to sysadmin types,
who might want to tune it.  mmu_notifier.txt is of interest to ...
somebody, but probably nobody who is thinking in user space.  And so on.

So I would really like to see this material split up and put into the
appropriate places in the RST hierarchy - admin-guide for administrative
stuff, core-api for kernel development topics, etc.  That, of course,
could be done separately from the RST conversion, but I suspect I know
what will (or will not) happen if we agree to defer that for now :)

The other is the inevitable merge conflicts that changing that many doc
files will create.  Sending the patches through Andrew could minimize
that, I guess, or at least make it his problem.  Alternatively, we could
try to do it as an end-of-merge-window sort of thing.  I can try to manage
that, but an ack or two from the mm crowd would be nice to have.

Thanks,

jon
