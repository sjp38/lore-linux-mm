Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id EE0F46B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 12:59:43 -0400 (EDT)
Received: by iecuq6 with SMTP id uq6so159782872iec.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 09:59:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o139si3162738ioo.84.2015.07.08.09.59.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 09:59:43 -0700 (PDT)
Date: Wed, 8 Jul 2015 10:00:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 0/5] Allow user to request memory to be locked on
 page fault
Message-Id: <20150708100008.e8a000ec.akpm@linux-foundation.org>
In-Reply-To: <20150708132302.GB4669@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
	<20150707141613.f945c98279dcb71c9743d5f2@linux-foundation.org>
	<20150708132302.GB4669@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Wed, 8 Jul 2015 09:23:02 -0400 Eric B Munson <emunson@akamai.com> wrote:

> > I don't know whether these syscalls should be documented via new
> > manpages, or if we should instead add them to the existing
> > mlock/munlock/mlockall manpages.  Michael, could you please advise?
> > 
> 
> Thanks for adding the series.  I owe you several updates (getting the
> new syscall right for all architectures and a set of tests for the new
> syscalls).  Would you prefer a new pair of patches or I update this set?

It doesn't matter much.  I guess a full update will be more convenient
at your end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
