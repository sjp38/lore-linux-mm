Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E389D6B0006
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 03:23:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id u6-v6so357607eds.10
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 00:23:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c19-v6si386417ejz.249.2018.10.23.00.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 00:23:08 -0700 (PDT)
Date: Tue, 23 Oct 2018 09:23:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181023072306.GN18839@dhcp22.suse.cz>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022165253.uphv3xzqivh44o3d@pc636>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Uladzislau Rezki <urezki@gmail.com>, Shuah Khan <shuah@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

Hi Shuah,

On Mon 22-10-18 18:52:53, Uladzislau Rezki wrote:
> On Mon, Oct 22, 2018 at 02:51:42PM +0200, Michal Hocko wrote:
> > Hi,
> > I haven't read through the implementation yet but I have say that I
> > really love this cover letter. It is clear on intetion, it covers design
> > from high level enough to start discussion and provides a very nice
> > testing coverage. Nice work!
> > 
> > I also think that we need a better performing vmalloc implementation
> > long term because of the increasing number of kvmalloc users.
> > 
> > I just have two mostly workflow specific comments.
> > 
> > > A test-suite patch you can find here, it is based on 4.18 kernel.
> > > ftp://vps418301.ovh.net/incoming/0001-mm-vmalloc-stress-test-suite-v4.18.patch
> > 
> > Can you fit this stress test into the standard self test machinery?
> > 
> If you mean "tools/testing/selftests", then i can fit that as a kernel module.
> But not all the tests i can trigger from kernel module, because 3 of 8 tests
> use __vmalloc_node_range() function that is not marked as EXPORT_SYMBOL.

Is there any way to conditionally export these internal symbols just for
kselftests? Or is there any other standard way how to test internal
functionality that is not exported to modules?
-- 
Michal Hocko
SUSE Labs
