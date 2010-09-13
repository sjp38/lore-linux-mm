Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B4F466B0047
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 15:26:33 -0400 (EDT)
Date: Mon, 13 Sep 2010 21:26:26 +0200
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: block cache replacement strategy?
Message-ID: <20100913192626.GA15092@sig21.net>
References: <20100907133429.GB3430@sig21.net>
 <20100909120044.GA27765@sig21.net>
 <20100910120235.455962c4@schatten.dmk.lab>
 <20100910160247.GA637@sig21.net>
 <20100913152138.GA16334@sig21.net>
 <AANLkTikoUAgRV18axesaiYnpBWe2V-xhALgh7dtF7p3Y@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikoUAgRV18axesaiYnpBWe2V-xhALgh7dtF7p3Y@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: dave b <db.pub.mail@gmail.com>
Cc: Florian Mickler <florian@mickler.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 14, 2010 at 05:09:31AM +1000, dave b wrote:
> On 14 September 2010 01:21, Johannes Stezenbach <js@sig21.net> wrote:
> > On Fri, Sep 10, 2010 at 06:02:48PM +0200, Johannes Stezenbach wrote:
> >>
> >> Linear read heuristic might be a good guess, but it would
> >> be nice to hear a comment from a vm/fs expert which
> >> confirms this works as intended.
> >
> > Anyway I found lmdd (from lmbench) can do random reads,
> > and indeed causes the data to enter the block (page?) cache,
> > replacing the previous data.
> 
> I am no expert, but what did you think would happen if you did dd
> twice from /dev/zero?
> but... Honestly what do you think will be cached?

It's not from /dev/zero, it is from file to /dev/null.

It all started with me wanting to compare disk read bandwidth
vs. read bandwidth of my root partition via dm-crypt + LVM,
and then wondering why dd from raw disk seemed to be
cached while dd from crypted root partition didn't.


Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
