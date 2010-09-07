Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A3E9F6B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 22:36:26 -0400 (EDT)
Date: Mon, 6 Sep 2010 19:34:31 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [RFCv5 0/9] CMA + VCMM integration
Message-ID: <20100907023431.GB11972@kroah.com>
References: <cover.1283749231.git.mina86@mina86.com> <20100906210905.GB5863@kroah.com> <op.vim2x8i87p4s8u@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.vim2x8i87p4s8u@localhost>
Sender: owner-linux-mm@kvack.org
To: Micha?? Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 07, 2010 at 03:40:46AM +0200, Micha?? Nazarewicz wrote:
> On Mon, 06 Sep 2010 23:09:05 +0200, Greg KH <greg@kroah.com> wrote:
>
>> On Mon, Sep 06, 2010 at 08:33:50AM +0200, Michal Nazarewicz wrote:
>>> Hello everyone,
>>>
>>> This patchset introduces a draft of a redesign of Zach Pfeffer's
>>> VCMM.
>>
>> What is a VCMM?
>
> Virtual Contiguous Memory Manager.  The version posted by Zach can
> be found at: <http://article.gmane.org/gmane.linux.kernel.mm/50090>.
> It is an API for managing IO MMU and IO MMU mappings.
>
>> What is a CMA?
>
> Contiguous Memory Manager.  The v4 version can be found at
> <http://marc.info/?l=linux-mm&m=128229799415817&w=2>.  It is an API for
> allocating large, physically contiguous blocks of memory.
>
> I haven't expected that anyone who haven't already participated in the
> discussion about CMA and VCMM will get interested by this patchset
> so I was a bit vague in the cover letter.  Sorry about that.
>
>>> Not all of the functionality of the original VCMM has been
>>> ported into this patchset.  This is mostly meant as RFC.  Moreover,
>>> the code for VCMM implementation in this RFC has not been tested.
>
>> If you haven't even tested it, why should we review it?
>
> Ignore the code then and look just at the documentation, please.
> I wanted to post what I have to receive comments about the general
> idea and not necessarily the code itself.  Code is just a mean to show
> how I see the implementation of the idea described in the documentation.
> Because of all that, I marked the patchset as a RFC rather than a PATCH.

Oops, I looked at the code, sorry :)

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
