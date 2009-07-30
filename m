Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 475E76B00BA
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 21:12:30 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id n6U1CT82027480
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 02:12:30 +0100
Received: from wf-out-1314.google.com (wff29.prod.google.com [10.142.6.29])
	by wpaz37.hot.corp.google.com with ESMTP id n6U1CQn8013583
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 18:12:26 -0700
Received: by wf-out-1314.google.com with SMTP id 29so352284wff.32
        for <linux-mm@kvack.org>; Wed, 29 Jul 2009 18:12:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090730010630.GA7326@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
	 <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
	 <20090729114322.GA9335@localhost>
	 <33307c790907290711s320607b0i79c939104d4c2d61@mail.gmail.com>
	 <20090730010630.GA7326@localhost>
Date: Wed, 29 Jul 2009 18:12:26 -0700
Message-ID: <33307c790907291812j40146a96tc2e9c5e097a33615@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chad Talbott <ctalbott@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, "sandeen@redhat.com" <sandeen@redhat.com>, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

> I agree on the unification of kupdate and sync paths. In fact I had a
> patch for doing this. And I'd recommend to do it in two patches:
> one to fix the congestion case, another to do the code unification.
>
> The sync path don't care whether requeue_io() or redirty_tail() is
> used, because they disregard the time stamps totally - only order of
> inodes matters (ie. starvation), which is same for requeue_io()/redirty_tail().

But, as I understand it, both paths share the same lists, so we still have
to be consistent?

Also, you set flags like more_io higher up in sync_sb_inodes() based on
whether there's anything in s_more_io queue, so it still seems to have
some effect to me?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
