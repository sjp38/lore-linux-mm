Date: Sat, 16 Jun 2007 01:59:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [4/6] page isolation
Message-Id: <20070616015944.f27fc6ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1181922406.28189.25.camel@spirit>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614160321.59314758.kamezawa.hiroyu@jp.fujitsu.com>
	<1181922406.28189.25.camel@spirit>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jun 2007 08:46:45 -0700
Dave Hansen <hansendc@us.ibm.com> wrote:

> +__first_valid_page(unsigned long pfn, unsigned long nr_page)
> > +{
> > +	int i;
> > +	struct page *page;
> > +	for (i = 0; i < nr_page; i++)
> > +		if (1)
> > +			break;
> > +	if (unlikely(i == nr_pages))
> > +		return NULL;
> > +	return pfn_to_page(pfn + i);
> > +}
> 
> I think the compiler can optimize that. :)
> 
ok, I'll take your advice.

Thank you.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
