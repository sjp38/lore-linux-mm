Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m56IKZDY017221
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 14:20:35 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m56IKXFM087034
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 12:20:35 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m56IKX9J025188
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 12:20:33 -0600
Subject: Re: [RFC][PATCH 1/2] pass mm into pagewalkers
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1212775572.14718.14.camel@calx>
References: <20080606173137.24513039@kernel>
	 <1212775572.14718.14.camel@calx>
Content-Type: text/plain
Date: Fri, 06 Jun 2008 11:20:32 -0700
Message-Id: <1212776432.7837.19.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-06 at 13:06 -0500, Matt Mackall wrote:
> On Fri, 2008-06-06 at 10:31 -0700, Dave Hansen wrote:
> > We need this at least for huge page detection for now.
> > 
> > It might also come in handy for some of the other
> > users.
> 
> This looks great, modulo some whitespace nits.

Looks like I snuck in a gratuitous \n in show_smap().  Any others you
want me to fix up?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
