Date: Tue, 12 Jun 2007 11:47:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070612050702.GT3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706121146050.30754@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
 <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com>
 <20070612023421.GL3798@us.ibm.com> <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com>
 <20070612031718.GP3798@us.ibm.com> <Pine.LNX.4.64.0706112018260.25631@schroedinger.engr.sgi.com>
 <20070612033050.GR3798@us.ibm.com> <Pine.LNX.4.64.0706112046380.25900@schroedinger.engr.sgi.com>
 <20070612050702.GT3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> Hrm, maybe that will work -- but then it means that if one is
> interleaving huge pages, it will interfere with the interleaving of
> small pages. Given that right now, huge pages are a rather precious
> commodity, do we want this?

The number of pages interleaved for small pages is quite high. So there
will not be a significant effect. If we use this counter then we can
fall back on existing functionality in the memory policy subsystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
