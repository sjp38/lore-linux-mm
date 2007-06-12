Date: Mon, 11 Jun 2007 20:48:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070612033050.GR3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706112046380.25900@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
 <20070612001542.GJ14458@us.ibm.com> <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
 <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com>
 <20070612023421.GL3798@us.ibm.com> <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com>
 <20070612031718.GP3798@us.ibm.com> <Pine.LNX.4.64.0706112018260.25631@schroedinger.engr.sgi.com>
 <20070612033050.GR3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> > Export a function for the interleave functionality so that we do not
> > have to replicate the same thing in various locations in the kernel.
> 
> But I don't understand this at all.
> 
> This is *not* generically available, unless every caller has its own
> private static variable. I don't know how to do that in C.

It is already there. Each task has a il_next field in its task struct for 
that purpose.

> You're asking me to complicate patches that work just fine right now.

I am trying to simplify your work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
