Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90E4B6B0010
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 16:09:27 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b7-v6so1268365pgt.10
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:09:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 4-v6si2248747pfe.142.2018.10.23.13.09.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 13:09:26 -0700 (PDT)
Date: Tue, 23 Oct 2018 13:09:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181023200923.GB25444@bombadil.infradead.org>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
 <20181023170532.GW18839@dhcp22.suse.cz>
 <98842edb-d462-96b1-311f-27c6ebfc108a@kernel.org>
 <20181023193044.GA139403@joelaf.mtv.corp.google.com>
 <024af44a-77e1-1c61-c9b2-64ffbe4f7c49@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <024af44a-77e1-1c61-c9b2-64ffbe4f7c49@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuah@kernel.org>
Cc: Joel Fernandes <joel@joelfernandes.org>, Michal Hocko <mhocko@kernel.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, maco@android.com

On Tue, Oct 23, 2018 at 01:48:32PM -0600, Shuah Khan wrote:
> On 10/23/2018 01:30 PM, Joel Fernandes wrote:
> > On Tue, Oct 23, 2018 at 11:13:36AM -0600, Shuah Khan wrote:
> >> I like this proposal. I think we will open up lot of test opportunities with
> >> this approach.
> >>
> >> Maybe we can use this stress test as a pilot and see where it takes us.
> > 
> > I am a bit worried that such an EXPORT_SYMBOL_KSELFTEST mechanism can be abused by
> > out-of-tree module writers to call internal functionality.
> 
> That is  valid concern to consider before we go forward with the proposal.
> 
> We could wrap EXPORT_SYMBOL_KSELFTEST this in an existing debug option. This could
> be fine grained for each sub-system for its debug option. We do have a few of these
> now

This all seems far more complicated than my proposed solution.
