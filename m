Date: Fri, 11 May 2007 10:05:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory hotremove patch take 2 [05/10] (make basic remove
 code)
Message-Id: <20070511100546.6464c711.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705101108251.10002@schroedinger.engr.sgi.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
	<20070509120512.B910.Y-GOTO@jp.fujitsu.com>
	<Pine.LNX.4.64.0705101108251.10002@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: y-goto@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007 11:09:29 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 9 May 2007, Yasunori Goto wrote:
> 
> > +/*
> > + * Just an easy implementation.
> > + */
> > +static struct page *
> > +hotremove_migrate_alloc(struct page *page,
> > +			unsigned long private,
> > +			int **x)
> > +{
> > +	return alloc_page(GFP_HIGH_MOVABLE);
> > +}
> 
> This would need to reflect the zone in which you are performing hot 
> remove. Or is hot remove only possible in the higest zone?
> 
No. We'll allow hot remove in any zone-type.
My old patchest didn't include Mel-san's page grouping and just had
ZONE_MOVABLE, so I wrote this. Reflecting migration target's zone here
is reasobanle. 

Anyway, I think we'll need more complicated function here.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
