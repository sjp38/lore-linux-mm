Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 738346B0096
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:16:54 -0400 (EDT)
Date: Wed, 17 Apr 2013 10:16:39 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366208199-50vqp1rm-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <516E446B.5060006@gmail.com>
References: <51662D5B.3050001@hitachi.com>
 <20130411134915.GH16732@two.firstfloor.org>
 <1365693788-djsd2ymu-mutt-n-horiguchi@ah.jp.nec.com>
 <516E446B.5060006@gmail.com>
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Apr 17, 2013 at 02:42:51PM +0800, Simon Jeons wrote:
> Hi Naoya,
> On 04/11/2013 11:23 PM, Naoya Horiguchi wrote:
> > On Thu, Apr 11, 2013 at 03:49:16PM +0200, Andi Kleen wrote:
> >>> As a result, if the dirty cache includes user data, the data is lost,
> >>> and data corruption occurs if an application uses old data.
> >> The application cannot use old data, the kernel code kills it if it
> >> would do that. And if it's IO data there is an EIO triggered.
> >>
> >> iirc the only concern in the past was that the application may miss
> >> the asynchronous EIO because it's cleared on any fd access. 
> >>
> >> This is a general problem not specific to memory error handling, 
> >> as these asynchronous IO errors can happen due to other reason
> >> (bad disk etc.) 
> >>
> >> If you're really concerned about this case I think the solution
> >> is to make the EIO more sticky so that there is a higher chance
> >> than it gets returned.  This will make your data much more safe,
> >> as it will cover all kinds of IO errors, not just the obscure memory
> >> errors.
> > I'm interested in this topic, and in previous discussion, what I was said
> > is that we can't expect user applications to change their behaviors when
> > they get EIO, so globally changing EIO's stickiness is not a great approach.
> 
> The user applications will get EIO firstly or get SIG_KILL firstly?

That depends on how the process accesses to the error page, so I can't
say which one comes first.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
