Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA6A6B0007
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:06:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h48-v6so1327728edh.22
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 10:06:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y15-v6si445845edd.10.2018.10.23.10.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 10:05:34 -0700 (PDT)
Date: Tue, 23 Oct 2018 19:05:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181023170532.GW18839@dhcp22.suse.cz>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023152640.GD20085@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Shuah Khan <shuah@kernel.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Tue 23-10-18 08:26:40, Matthew Wilcox wrote:
> On Tue, Oct 23, 2018 at 09:02:56AM -0600, Shuah Khan wrote:
[...]
> > The way it can be handled is by adding a test module under lib. test_kmod,
> > test_sysctl, test_user_copy etc.
> 
> The problem is that said module can only invoke functions which are
> exported using EXPORT_SYMBOL.  And there's a cost to exporting them,
> which I don't think we're willing to pay, purely to get test coverage.

Yes, I think we do not want to export internal functionality which might
be still interesting for the testing coverage. Maybe we want something
like EXPORT_SYMBOL_KSELFTEST which would allow to link within the
kselftest machinery but it wouldn't allow the same for general modules
and will not give any API promisses.

I wouldn't be surprised if we found some cases of EXPORT_SYMBOL* just to
make a symbol available for testing which would be unfortunate.
-- 
Michal Hocko
SUSE Labs
