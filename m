Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f176.google.com (mail-gg0-f176.google.com [209.85.161.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4A19F6B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 18:36:49 -0500 (EST)
Received: by mail-gg0-f176.google.com with SMTP id l12so2913930gge.21
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 15:36:48 -0800 (PST)
Received: from mail-yh0-x234.google.com (mail-yh0-x234.google.com [2607:f8b0:4002:c01::234])
        by mx.google.com with ESMTPS id s6si242270yho.89.2014.01.02.15.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 15:36:47 -0800 (PST)
Received: by mail-yh0-f52.google.com with SMTP id i7so2994682yha.39
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 15:36:47 -0800 (PST)
Date: Thu, 2 Jan 2014 15:36:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
In-Reply-To: <52C5E3C2.6020205@intel.com>
Message-ID: <alpine.DEB.2.02.1401021534320.492@chino.kir.corp.google.com>
References: <20140101002935.GA15683@localhost.localdomain> <52C5AA61.8060701@intel.com> <alpine.DEB.2.02.1401021357360.21537@chino.kir.corp.google.com> <52C5E3C2.6020205@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Thu, 2 Jan 2014, Dave Hansen wrote:

> > The default value of min_free_kbytes depends on the implementation of the 
> > VM regardless of any config options that you may have enabled.  We don't 
> > specify what the non-thp default is in the kernel log, so why do we need 
> > to specify what the thp default is?
> 
> Let's say enabling THP made my system behave badly.  How do I get it
> back to the state before I enabled THP?  The user has to have gone and
> recorded what their min_free_kbytes was before turning THP on in order
> to get it back to where it was.  Folks also have to either plan in
> advance (archiving *ALL* the sysctl settings), somehow *know* somehow
> that THP can affect min_free_kbytes, or just plain be clairvoyant.
> 

How is this different from some initscript changing the value?  We should 
either specify that min_free_kbytes changed from its default, which may 
change from kernel version to kernel version itself, in all cases or just 
leave it as it currently is.  There's no reason to special-case thp in 
this way if there are other ways to change the value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
