Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 4BD3D6B005C
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 03:59:07 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8E81A3EE0BD
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 17:59:05 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 772BB3266C1
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 17:59:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EDDC206FC2
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 17:59:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DAA91DB8040
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 17:59:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0736F1DB804C
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 17:59:05 +0900 (JST)
Date: Mon, 30 Jan 2012 17:57:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
Message-Id: <20120130175730.de654d9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <22f6781b-9cc4-4857-b3e1-e2d9f595f64d@default>
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
	<4F218D36.2060308@linux.vnet.ibm.com>
	<9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
	<20120126163150.31a8688f.akpm@linux-foundation.org>
	<ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
	<20120126171548.2c85dd44.akpm@linux-foundation.org>
	<7198bfb3-1e32-40d3-8601-d88aed7aabd8@default>
	<4F221AFE.6070108@redhat.com>
	<22f6781b-9cc4-4857-b3e1-e2d9f595f64d@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, Chris Mason <chris.mason@oracle.com>

On Thu, 26 Jan 2012 21:15:16 -0800 (PST)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > From: Rik van Riel [mailto:riel@redhat.com]
> > Subject: Re: [PATCH] mm: implement WasActive page flag (for improving cleancache)
> > 
> > On 01/26/2012 09:43 PM, Dan Magenheimer wrote:
> > 
> > > Maybe the Active page bit could be overloaded with some minor
> > > rewriting?  IOW, perhaps the Active bit could be ignored when
> > > the page is moved to the inactive LRU?  (Confusing I know, but I am
> > > just brainstorming...)
> > 
> > The PG_referenced bit is already overloaded.  We keep
> > the bit set when we move a page from the active to the
> > inactive list, so a page that was previously active
> > only needs to be referenced once to become active again.
> > 
> > The LRU bits (PG_lru, PG_active, etc) are needed to
> > figure out which LRU list the page is on.  I don't
> > think we can overload those...
> 
> I suspected that was true, but was just brainstorming.
> Thanks for confirming.
> 
> Are there any other page bits that are dont-care when
> a page is on an LRU list?
> 
> I'd also be interested in your/RedHat's opinion on the
> 64-bit vs 32-bit market.  Will RHEL7 even support 32-bit?
> 

How about replacing PG_slab ? 

I think  PageSlab(page) be implemented as

#define SLABMAGIC		(some value)
#define PageSlab(page)		(page->mapping == SLABMAGIC) 

or some...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
