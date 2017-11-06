Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7C386B0261
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 07:12:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 198so3527515wmg.8
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 04:12:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i92si1114814edc.472.2017.11.06.04.12.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 04:12:23 -0800 (PST)
Date: Mon, 6 Nov 2017 13:12:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use in_atomic() in print_vma_addr()
Message-ID: <20171106121222.nnzrr4cb7s7y5h74@dhcp22.suse.cz>
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
 <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
 <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
 <20171103110245.7049460a05cc18c7e8a9feb2@linux-foundation.org>
 <1509739786.2473.33.camel@wdc.com>
 <20171105081946.yr2pvalbegxygcky@dhcp22.suse.cz>
 <20171106100558.GD3165@worktop.lehotels.local>
 <20171106104354.2jlgd2m4j4gxx4qo@dhcp22.suse.cz>
 <20171106120025.GH3165@worktop.lehotels.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106120025.GH3165@worktop.lehotels.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Bart Van Assche <Bart.VanAssche@wdc.com>, "yang.s@alibaba-inc.com" <yang.s@alibaba-inc.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "joe@perches.com" <joe@perches.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@redhat.com" <mingo@redhat.com>

On Mon 06-11-17 13:00:25, Peter Zijlstra wrote:
> On Mon, Nov 06, 2017 at 11:43:54AM +0100, Michal Hocko wrote:
> > > Yes the comment is very much accurate.
> > 
> > Which suggests that print_vma_addr might be problematic, right?
> > Shouldn't we do trylock on mmap_sem instead?
> 
> Yes that's complete rubbish. trylock will get spurious failures to print
> when the lock is contended.

Yes, but I guess that it is acceptable to to not print the state under
that condition.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
