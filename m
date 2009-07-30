Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8ED6B0082
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 22:59:16 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n6U2xDvB016433
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 19:59:13 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by spaceape11.eur.corp.google.com with ESMTP id n6U2x94g025034
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 19:59:10 -0700
Received: by pzk2 with SMTP id 2so227093pzk.30
        for <linux-mm@kvack.org>; Wed, 29 Jul 2009 19:59:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090730015754.GC7326@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
	 <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
	 <20090729114322.GA9335@localhost>
	 <33307c790907290711s320607b0i79c939104d4c2d61@mail.gmail.com>
	 <20090730010630.GA7326@localhost>
	 <33307c790907291812j40146a96tc2e9c5e097a33615@mail.gmail.com>
	 <20090730015754.GC7326@localhost>
Date: Wed, 29 Jul 2009 19:59:09 -0700
Message-ID: <33307c790907291959r47b1bd3ap7cfa06fd5154aaad@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chad Talbott <ctalbott@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, "sandeen@redhat.com" <sandeen@redhat.com>, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 29, 2009 at 6:57 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> On Thu, Jul 30, 2009 at 09:12:26AM +0800, Martin Bligh wrote:
>> > I agree on the unification of kupdate and sync paths. In fact I had a
>> > patch for doing this. And I'd recommend to do it in two patches:
>> > one to fix the congestion case, another to do the code unification.
>> >
>> > The sync path don't care whether requeue_io() or redirty_tail() is
>> > used, because they disregard the time stamps totally - only order of
>> > inodes matters (ie. starvation), which is same for requeue_io()/redirty_tail().
>>
>> But, as I understand it, both paths share the same lists, so we still have
>> to be consistent?
>
> Then let's first unify the code, then fix the congestion case? :)

OK, I will send it out as separate patches. I am just finishing up the testing
first.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
