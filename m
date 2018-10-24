Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07D736B000A
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 02:22:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v15-v6so2304226edm.13
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 23:22:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5-v6si984285ejf.66.2018.10.23.23.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 23:22:55 -0700 (PDT)
Date: Wed, 24 Oct 2018 08:22:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181024062252.GA18839@dhcp22.suse.cz>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
 <20181023170532.GW18839@dhcp22.suse.cz>
 <98842edb-d462-96b1-311f-27c6ebfc108a@kernel.org>
 <20181023193044.GA139403@joelaf.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023193044.GA139403@joelaf.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Shuah Khan <shuah@kernel.org>, Matthew Wilcox <willy@infradead.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, maco@android.com

On Tue 23-10-18 12:30:44, Joel Fernandes wrote:
> On Tue, Oct 23, 2018 at 11:13:36AM -0600, Shuah Khan wrote:
> > On 10/23/2018 11:05 AM, Michal Hocko wrote:
> > > On Tue 23-10-18 08:26:40, Matthew Wilcox wrote:
> > >> On Tue, Oct 23, 2018 at 09:02:56AM -0600, Shuah Khan wrote:
> > > [...]
> > >>> The way it can be handled is by adding a test module under lib. test_kmod,
> > >>> test_sysctl, test_user_copy etc.
> > >>
> > >> The problem is that said module can only invoke functions which are
> > >> exported using EXPORT_SYMBOL.  And there's a cost to exporting them,
> > >> which I don't think we're willing to pay, purely to get test coverage.
> > > 
> > > Yes, I think we do not want to export internal functionality which might
> > > be still interesting for the testing coverage. Maybe we want something
> > > like EXPORT_SYMBOL_KSELFTEST which would allow to link within the
> > > kselftest machinery but it wouldn't allow the same for general modules
> > > and will not give any API promisses.
> > > 
> > 
> > I like this proposal. I think we will open up lot of test opportunities with
> > this approach.
> > 
> > Maybe we can use this stress test as a pilot and see where it takes us.
> 
> I am a bit worried that such an EXPORT_SYMBOL_KSELFTEST mechanism can be abused by
> out-of-tree module writers to call internal functionality.
> 
> How would you prevent that?

There is no way to prevent non-exported symbols abuse by 3rd party
AFAIK. EXPORT_SYMBOL_* is not there to prohibid abuse. It is a mere
signal of what is, well, an exported API.
-- 
Michal Hocko
SUSE Labs
