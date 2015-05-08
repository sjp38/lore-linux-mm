Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 83A006B0038
	for <linux-mm@kvack.org>; Fri,  8 May 2015 16:49:03 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so96772947pdb.2
        for <linux-mm@kvack.org>; Fri, 08 May 2015 13:49:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ea16si8472297pad.208.2015.05.08.13.49.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 13:49:02 -0700 (PDT)
Date: Fri, 8 May 2015 13:49:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 0/3] Find mirrored memory, use for boot time
 allocations
Message-Id: <20150508134901.e3e7585b359b073253788c22@linux-foundation.org>
In-Reply-To: <CA+8MBbLNO5PdsdVtwweCuGohWkns2sCijkOCj4qHjo0HptEHFg@mail.gmail.com>
References: <cover.1431103461.git.tony.luck@intel.com>
	<20150508130307.e9bfedcfc66cbe6e6b009f19@linux-foundation.org>
	<CA+8MBbLNO5PdsdVtwweCuGohWkns2sCijkOCj4qHjo0HptEHFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 8 May 2015 13:38:52 -0700 Tony Luck <tony.luck@gmail.com> wrote:

> > Will surplus ZONE_MIRROR memory be available for regular old movable
> > allocations?
> ZONE_MIRROR and ZONE_MOVABLE are pretty much opposites. We
> only want kernel allocations in mirror memory, and we can't allow any
> kernel allocations in movable (cause they'll pin it).

What I mean is: allow userspace to consume ZONE_MIRROR memory because
we can snatch it back if it is needed for kernel memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
