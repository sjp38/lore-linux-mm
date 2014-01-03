Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f51.google.com (mail-qe0-f51.google.com [209.85.128.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA016B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 22:33:10 -0500 (EST)
Received: by mail-qe0-f51.google.com with SMTP id 1so14879807qee.38
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 19:33:09 -0800 (PST)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id j9si25070748qcf.59.2014.01.02.19.33.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Jan 2014 19:33:09 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Thu, 2 Jan 2014 22:33:08 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 432D238C8027
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 22:33:04 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s033X6WJ66846964
	for <linux-mm@kvack.org>; Fri, 3 Jan 2014 03:33:06 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s033X6hv020280
	for <linux-mm@kvack.org>; Thu, 2 Jan 2014 22:33:06 -0500
Date: Fri, 3 Jan 2014 11:33:03 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140103033303.GB4106@localhost.localdomain>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52C5AA61.8060701@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Thu, Jan 02, 2014 at 10:05:21AM -0800, Dave Hansen wrote:
> On 12/31/2013 04:29 PM, Han Pingtian wrote:
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
> "raising min_free_kbytes from %d to %d to help transparent hugepage
> allocations"
> 
Thanks. I have updated it according to your suggestion.
