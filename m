Subject: Re: [RFC] per thread page reservation patch
From: Robert Love <rml@novell.com>
In-Reply-To: <20050107190545.GA13898@infradead.org>
References: <20050103011113.6f6c8f44.akpm@osdl.org>
	 <20050103114854.GA18408@infradead.org> <41DC2386.9010701@namesys.com>
	 <1105019521.7074.79.camel@tribesman.namesys.com>
	 <20050107144644.GA9606@infradead.org>
	 <1105118217.3616.171.camel@tribesman.namesys.com>
	 <20050107190545.GA13898@infradead.org>
Content-Type: text/plain
Date: Fri, 07 Jan 2005 14:21:16 -0500
Message-Id: <1105125676.9311.27.camel@betsy.boston.ximian.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Vladimir Saveliev <vs@namesys.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-01-07 at 19:05 +0000, Christoph Hellwig wrote:

> int perthread_pages_reserve(int nrpages, int gfp)
> {
> 	LIST_HEAD(accumulator);
> 	int i;
> 
> 	list_splice_init(&current->private_pages, &accumulator);
> 
> Now the big question is, what's synchronizing access to
> current->private_pages?

Safe without locks so long as there is no other way to get at another
process's private_pages. ;)

Best,

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
