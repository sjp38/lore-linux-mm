Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9R0UVLv035896
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 20:30:31 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9R0UVd6150514
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 18:30:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9R0UUf5002618
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 18:30:30 -0600
Subject: Re: [RFC] remove highmem_start_page
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041026172359.3059edec.akpm@osdl.org>
References: <1098820614.5633.3.camel@localhost>
	 <20041026172359.3059edec.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1098837030.9408.2.camel@localhost>
Mime-Version: 1.0
Date: Tue, 26 Oct 2004 17:30:30 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-10-26 at 17:23, Andrew Morton wrote:
> Dave Hansen <haveblue@us.ibm.com> wrote:
> >
> > +static inline int page_is_highmem(struct page *page)
> > +{
> > +	return PageHighMem(page);
> > +}
> 
> (boggle).  Why not just use PageHighMem() directly?

Because I was doing another, more complex, calculation before that and
realized about PageHighMem() later on.  Would have also made it easier
to fix if someone came up with a better way when I posted the patch :)
I take it you'd rather just see it called directly.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
