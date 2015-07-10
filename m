Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 301396B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 12:11:36 -0400 (EDT)
Received: by obbop1 with SMTP id op1so194142910obb.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 09:11:35 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id sv3si7029208oeb.72.2015.07.10.09.11.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jul 2015 09:11:35 -0700 (PDT)
Date: Fri, 10 Jul 2015 10:11:18 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH V3 3/5] mm: mlock: Introduce VM_LOCKONFAULT and add
 mlock flags to enable it
Message-ID: <20150710101118.5d04d627@lwn.net>
In-Reply-To: <20150709184635.GE4669@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
	<1436288623-13007-4-git-send-email-emunson@akamai.com>
	<20150708132351.61c13db6@lwn.net>
	<20150708203456.GC4669@akamai.com>
	<20150708151750.75e65859@lwn.net>
	<20150709184635.GE4669@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Thu, 9 Jul 2015 14:46:35 -0400
Eric B Munson <emunson@akamai.com> wrote:

> > One other question...if I call mlock2(MLOCK_ONFAULT) on a range that
> > already has resident pages, I believe that those pages will not be locked
> > until they are reclaimed and faulted back in again, right?  I suspect that
> > could be surprising to users.  
> 
> That is the case.  I am looking into what it would take to find only the
> present pages in a range and lock them, if that is the behavior that is
> preferred I can include it in the updated series.

For whatever my $0.02 is worth, I think that should be done.  Otherwise
the mlock2() interface is essentially nondeterministic; you'll never
really know if a specific page is locked or not.

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
