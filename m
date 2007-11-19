Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJJh4ON032345
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:43:04 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAJJh4PZ113622
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:43:04 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJJh45t009358
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:43:04 -0500
Subject: Re: [RFC 5/7] LTTng instrumentation mm
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071119185258.GA998@Krystal>
References: <20071113193349.214098508@polymtl.ca>
	 <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost>
	 <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost>
	 <20071116144742.GA17255@Krystal> <1195495626.27759.119.camel@localhost>
	 <20071119185258.GA998@Krystal>
Content-Type: text/plain
Date: Mon, 19 Nov 2007 11:43:01 -0800
Message-Id: <1195501381.27759.127.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-11-19 at 13:52 -0500, Mathieu Desnoyers wrote:
> > > So I guess the result is a pointer ? Should this be expected ?
> > 
> > Nope.  'pointer - pointer' is an integer.  Just solve this equation for
> > integer:
> > 
> >       'pointer + integer = pointer'
> > 
> 
> Well, using page_to_pfn turns out to be ugly in markers (and in
> printks) then. Depending on the architecture, it will result in either
> an unsigned long (x86_64) or an unsigned int (i386), which corresponds
> to %lu or %u and will print a warning if we don't cast it explicitly. 

Casting the i386 one to be an unconditional 'unsigned long' shouldn't be
an issue.  We don't generally expect pfns to fit into ints anyway. 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
