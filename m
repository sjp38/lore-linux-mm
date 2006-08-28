Date: Mon, 28 Aug 2006 14:44:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
In-Reply-To: <1156798397.5408.23.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0608281443270.29055@schroedinger.engr.sgi.com>
References: <20060828154413.E05721BD@localhost.localdomain>
 <Pine.LNX.4.64.0608280954100.27677@schroedinger.engr.sgi.com>
 <1156798397.5408.23.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Aug 2006, Dave Hansen wrote:

> On Mon, 2006-08-28 at 10:01 -0700, Christoph Lameter wrote:
> > Note that there is a generic ALIGN macro in include/linux/kernel.h plus
> > __ALIGNs in linux/linkage.h. Could you use that and get to some sane 
> > conventin for all these ALIGN functions?
> 
> The one in kernel.h should certainly be consolidated.  What would you
> think about a linux/macros.h that had things like ARRAY_SIZE and the
> ALIGN macros, but didn't have any outside dependencies?  How about a
> linux/align.h just for the alignment macros?

linux/align.h sounds best. macros.h would lead to the accumulation of 
random macros.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
