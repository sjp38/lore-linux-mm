Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1CM4NNf014165
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 17:04:23 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1CM4DB9205260
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 15:04:19 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1CM4Caa000942
	for <linux-mm@kvack.org>; Tue, 12 Feb 2008 15:04:12 -0700
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1202853434.11188.76.camel@nimitz.home.sr71.net>
References: <20080211114818.74c9dcc7.akpm@linux-foundation.org>
	 <1202765553.25604.12.camel@dyn9047017100.beaverton.ibm.com>
	 <20080212154309.F9DA.Y-GOTO@jp.fujitsu.com>
	 <1202836953.25604.42.camel@dyn9047017100.beaverton.ibm.com>
	 <1202849972.11188.71.camel@nimitz.home.sr71.net>
	 <1202853415.25604.59.camel@dyn9047017100.beaverton.ibm.com>
	 <1202853434.11188.76.camel@nimitz.home.sr71.net>
Content-Type: text/plain
Date: Tue, 12 Feb 2008 14:07:11 -0800
Message-Id: <1202854031.25604.62.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, greg@kroah.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-12 at 13:57 -0800, Dave Hansen wrote:
> On Tue, 2008-02-12 at 13:56 -0800, Badari Pulavarty wrote:
> > 
> > +static void __remove_section(struct zone *zone, unsigned long
> > section_nr)
> > +{
> > +       if (!valid_section_nr(section_nr))
> > +               return;
> > +
> > +       unregister_memory_section(__nr_to_section(section_nr));
> > +       sparse_remove_one_section(zone, section_nr);
> > +}
> 
> I do think passing in a mem_section* here is highly superior.  It makes
> it impossible to pass a pfn in and not get a warning.
> 

Only problem is, I need to hold pgdat_resize_lock() if pass *ms. 
If I don't hold the resize_lock, I have to re-evaluate. And also,
I need to pass section_nr for decoding the mem_map anyway :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
