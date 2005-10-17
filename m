Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9HBec2X007659
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 07:40:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9HBgJeo415952
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 05:42:19 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9HBgJUx007897
	for <linux-mm@kvack.org>; Mon, 17 Oct 2005 05:42:19 -0600
Subject: Re: [Patch 2/3] Export get_one_pte_map.
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051017113131.GA30898@lnx-holt.americas.sgi.com>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com>
	 <20051014192225.GD14418@lnx-holt.americas.sgi.com>
	 <20051014213038.GA7450@kroah.com>
	 <20051017113131.GA30898@lnx-holt.americas.sgi.com>
Content-Type: text/plain
Date: Mon, 17 Oct 2005 13:41:52 +0200
Message-Id: <1129549312.32658.32.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Greg KH <greg@kroah.com>, ia64 list <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@infradead.org, jgarzik@pobox.com, William Lee Irwin III <wli@holomorphy.com>, Jack Steiner <steiner@americas.sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-10-17 at 06:31 -0500, Robin Holt wrote:
> On Fri, Oct 14, 2005 at 02:30:38PM -0700, Greg KH wrote:
> > On Fri, Oct 14, 2005 at 02:22:25PM -0500, Robin Holt wrote:
> > > +EXPORT_SYMBOL(get_one_pte_map);
> > 
> > EXPORT_SYMBOL_GPL() ?
> 
> Not sure why it would fall that way.  Looking at the directory,
> I get:

Most of the VM stuff in those directories that you're referring to are
old, crusty exports, from the days before _GPL.  We've left them to be
polite, but if many of them were recreated today, they'd certainly be
_GPL.

We do not want random external modules poking at PTEs, nor should a
module need to know such kernel internals as the semantics of
PTE_HIGHMEM.  I think it needs _GPL.

BTW, your new patches look much nicer than the last set.  Thanks for
making the changes I suggested.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
