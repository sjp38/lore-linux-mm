Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f179.google.com (mail-gg0-f179.google.com [209.85.161.179])
	by kanga.kvack.org (Postfix) with ESMTP id 81FC76B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:58:56 -0500 (EST)
Received: by mail-gg0-f179.google.com with SMTP id l4so2878314ggi.24
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:58:56 -0800 (PST)
Received: from mail-gg0-x234.google.com (mail-gg0-x234.google.com [2607:f8b0:4002:c02::234])
        by mx.google.com with ESMTPS id z48si7721yha.281.2014.01.02.13.58.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 13:58:55 -0800 (PST)
Received: by mail-gg0-f180.google.com with SMTP id k1so2890116gga.25
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:58:55 -0800 (PST)
Date: Thu, 2 Jan 2014 13:58:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
In-Reply-To: <52C5AA61.8060701@intel.com>
Message-ID: <alpine.DEB.2.02.1401021357360.21537@chino.kir.corp.google.com>
References: <20140101002935.GA15683@localhost.localdomain> <52C5AA61.8060701@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Thu, 2 Jan 2014, Dave Hansen wrote:

> > min_free_kbytes may be updated during thp's initialization. Sometimes,
> > this will change the value being set by user. Showing message will
> > clarify this confusion.
> ...
> > -	if (recommended_min > min_free_kbytes)
> > +	if (recommended_min > min_free_kbytes) {
> >  		min_free_kbytes = recommended_min;
> > +		pr_info("min_free_kbytes is updated to %d by enabling transparent hugepage.\n",
> > +			min_free_kbytes);
> > +	}
> 
> "updated" doesn't tell us much.  It's also kinda nasty that if we enable
> then disable THP, we end up with an elevated min_free_kbytes.  Maybe we
> should at least put something in that tells the user how to get back
> where they were if they care:
> 

The default value of min_free_kbytes depends on the implementation of the 
VM regardless of any config options that you may have enabled.  We don't 
specify what the non-thp default is in the kernel log, so why do we need 
to specify what the thp default is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
