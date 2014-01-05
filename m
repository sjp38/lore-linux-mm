Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 883AF6B0031
	for <linux-mm@kvack.org>; Sat,  4 Jan 2014 19:35:10 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id uz6so17189103obc.9
        for <linux-mm@kvack.org>; Sat, 04 Jan 2014 16:35:10 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id rj3si51807002oeb.55.2014.01.04.16.35.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 16:35:09 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <hanpt@linux.vnet.ibm.com>;
	Sat, 4 Jan 2014 17:35:08 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id DD3933E4003E
	for <linux-mm@kvack.org>; Sat,  4 Jan 2014 17:35:05 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s050YtH26816108
	for <linux-mm@kvack.org>; Sun, 5 Jan 2014 01:34:55 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s050Z5B8005875
	for <linux-mm@kvack.org>; Sat, 4 Jan 2014 17:35:05 -0700
Date: Sun, 5 Jan 2014 08:35:01 +0800
From: Han Pingtian <hanpt@linux.vnet.ibm.com>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140105003501.GC4106@localhost.localdomain>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52C6FED2.7070700@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On Fri, Jan 03, 2014 at 10:17:54AM -0800, Dave Hansen wrote:
> On 01/02/2014 07:33 PM, Han Pingtian wrote:
> > @@ -130,8 +130,11 @@ static int set_recommended_min_free_kbytes(void)
> >  			      (unsigned long) nr_free_buffer_pages() / 20);
> >  	recommended_min <<= (PAGE_SHIFT-10);
> >  
> > -	if (recommended_min > min_free_kbytes)
> > +	if (recommended_min > min_free_kbytes) {
> > +		pr_info("raising min_free_kbytes from %d to %d to help transparent hugepage allocations\n",
> > +			min_free_kbytes, recommended_min);
> >  		min_free_kbytes = recommended_min;
> > +	}
> >  	setup_per_zone_wmarks();
> >  	return 0;
> >  }
> 
> I know I gave you that big bloated string, but 108 columns is a _wee_
> bit over 80. :)
> 
> Otherwise, I do like the new message

Thanks. This is the new version:
