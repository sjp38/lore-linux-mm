Date: Thu, 5 Apr 2007 13:07:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Free up page->private for compound pages
In-Reply-To: <Pine.LNX.4.64.0704052006320.21325@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0704051302080.11287@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704042016490.7885@schroedinger.engr.sgi.com>
 <20070405033648.GG11192@wotan.suse.de> <Pine.LNX.4.64.0704042037550.8745@schroedinger.engr.sgi.com>
 <20070405035741.GH11192@wotan.suse.de> <Pine.LNX.4.64.0704042102570.12297@schroedinger.engr.sgi.com>
 <20070405042502.GI11192@wotan.suse.de> <Pine.LNX.4.64.0704042132170.14005@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704051522510.24160@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0704051117110.9800@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704051919490.17494@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0704051152500.10694@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704052006320.21325@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2007, Hugh Dickins wrote:

> > I am not so much worried about performance but more about the availability 
> > of the page->private field of compound pages.
> 
> Yes, I realise that.  I meant
> 	if (unlikely(PageCompound(page)) && PageTail(page))
> shouldn't slow down the !PageCompound fast paths more than the existing
> 	if (unlikely(PageCompound(page)))
> or the
> 	if (unlikely(PageTail(page)))
> you had.

Right.

> > I think we cannot overload the page flag after all because of the page 
> > count issue you pointed out. Guess I should be cleaning up my 
> > initial patch and repost it?
> 
> I still think PageTail is not worth its own distinct page flag:

Well I think we just killed 2 flags for software suspend. Did I not earn 
at least one by being involved in that project? ;-)

> I can understand you drawing back from my page+1 suggestion,
> but I don't understand why you're so reluctant to say
> 	if (unlikely(PageCompound(page)) && PageTail(page))

Thats fine with me. Ahh.. This would solve the alias issue.... (Lights
going on). Okay we can overload after all. Need to add some comments 
though.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
