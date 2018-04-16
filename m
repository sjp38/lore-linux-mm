Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28D806B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:35:43 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 61-v6so10926519plz.20
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 13:35:43 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id f31-v6si12938893plb.212.2018.04.16.13.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 13:35:41 -0700 (PDT)
Date: Mon, 16 Apr 2018 14:35:38 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 00/32] docs/vm: convert to ReST format
Message-ID: <20180416143538.40a40457@lwn.net>
In-Reply-To: <20180415173655.GB31176@rapoport-lnx>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
	<20180329154607.3d8bda75@lwn.net>
	<20180401063857.GA3357@rapoport-lnx>
	<20180413135551.0e6d1b12@lwn.net>
	<20180415173655.GB31176@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, 15 Apr 2018 20:36:56 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> I didn't mean we should keep it as unorganized jumble of stuff and I agree
> that splitting the documentation by audience is better because developers
> are already know how to find it :)
> 
> I just thought that putting the doc into the place should not be done
> immediately after mechanical ReST conversion but rather after improving the
> contents.

OK, this is fine.  I'll go ahead and apply the set, but then I'll be
watching to see that the other improvements come :)

In applying the set, there was a significant set of conflicts with
vm/hmm.rst; hopefully I've sorted those out properly.

Thanks,

jon
