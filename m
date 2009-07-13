Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 146CB6B0062
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 07:09:28 -0400 (EDT)
Date: Mon, 13 Jul 2009 13:32:06 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
Message-ID: <20090713113206.GB3452@wotan.suse.de>
References: <20090708104701.GA31419@infradead.org> <20090708123412.GQ2714@wotan.suse.de> <4A54C435.1000503@panasas.com> <20090709075100.GU2714@wotan.suse.de> <4A59A517.1080605@panasas.com> <20090712144717.GA18163@infradead.org> <20090713065917.GO14666@wotan.suse.de> <4A5AF637.3090405@panasas.com> <20090713090056.GA3452@wotan.suse.de> <4A5B17E3.3070908@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A5B17E3.3070908@panasas.com>
Sender: owner-linux-mm@kvack.org
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 02:17:55PM +0300, Boaz Harrosh wrote:
> On 07/13/2009 12:00 PM, Nick Piggin wrote:
> > AFAIKS inode_setattr basically is simple_setattr, so I think at some
> > point it should just get renamed to simple_setattr. Adding
> > simple_setattr_nosize or similar helper would be fine too. I don't
> > care much about the exact details... But anyway these things are not
> > so important to this truncate patchset at the moment.
> > 
> 
> I see. So what is the schedule? when are we to convert all FSs?

Well the changes can be back compatible, and there is not too
much complexity to support the current system, so I guess it
will just be done as soon as somebody writes the patches.

But probably it is a good idea to convert any filesystem using
->truncate to the new sequence at the same time (ie. don't
just simply add .setattr = simple_setattr, and rely on its calling
vmtruncate, but actually DTRT and remove .truncate at the
same time).

Any patches would be welcome, for any filesystem. Probably it
won't exactly be a rapid process, judging by past experience.


> >> [BTW these changes are a life saver for me in regard to
> >> the kind of things I need to do for pNFS-exports]
> > 
> > You mean the truncate patches? Well that's nice to know. I
> > guess it has always been possible just to redefine your own
> > setattr, but now it should be a bit nicer with the truncate
> > helpers...
> > 
> 
> OK, yes redefine .setattr, do the right thing in write_begin/end
> and the helpers do help a lot, to the point that it was not safe to
> open-code all this work. The situation is much better after your
> patchset.

OK good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
