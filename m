Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 18 Dec 2008 12:40:20 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: test
Message-ID: <20081218114020.GA17966@logfs.org>
References: <20081215192319.GF10471@kvack.org> <20081217153312.GA11815@logfs.org> <20081217165233.GD4247@kvack.org> <20081217183428.GB11815@logfs.org> <20081218010343.GC23506@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20081218010343.GC23506@kvack.org>
Sender: owner-linux-mm@kvack.org
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 December 2008 20:03:43 -0500, Benjamin LaHaise wrote:
> 
> > Any chance that kvack can set either X-BeenThere: or X-Mailing-List: as
> > almost every other mailing list (the ppc ones set X-Original-To, alas)
> > does?
> 
> I don't see the point in adding it when the Sender: header works fine for 
> me.  Right now I'm more worried about the state of the spam filtering.

Maybe I'm a special kid.  I have two filters for mailing lists.  The
first simply tries to detect whether the mail comes from _any_ mailing
list.  The second then sorts it into the appropriate mailbox.  Anything
left over goes into unsorted (95% spam) or list/unsorted (<1% spam) if
it matched the generic mailing list rule, but no specific one.
list/unsorted usually fills up after subscribing to a new list or when
something changed.  Not having all the spam mixed in is nice.

My rule to detect mailing lists is this:
 * ^(X-Mailing-List:|X-BeenThere:|X-Original-To:|Original-Recipient:|X-Loop:) 

If it weren't for kvack.org and ozlabs.org, it could be just this:
 * ^(X-Mailing-List:|X-BeenThere:)

Not exactly the most important issue for humanity, that's for sure. :)

JA?rn

-- 
There's nothing that will change someone's moral outlook quicker
than cash in large sums.
-- Larry Flynt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
