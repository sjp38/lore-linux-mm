Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF036B0006
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:02:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x44-v6so4988666edd.17
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 05:02:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14-v6si10086214ejj.220.2018.10.11.05.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 05:02:11 -0700 (PDT)
Date: Thu, 11 Oct 2018 14:02:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Message-ID: <20181011120209.GV5873@dhcp22.suse.cz>
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <20181009220222.26nzajhpsbt7syvv@kshutemo-mobl1>
 <20181009230447.GA17911@joelaf.mtv.corp.google.com>
 <20181010100011.6jqjvgeslrvvyhr3@kshutemo-mobl1>
 <20181011004618.GA237677@joelaf.mtv.corp.google.com>
 <20181011081719.77f7ihcy6mu2vkkc@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181011081719.77f7ihcy6mu2vkkc@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Joel Fernandes <joel@joelfernandes.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@android.com, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu 11-10-18 11:17:19, Kirill A. Shutemov wrote:
[...]
> > The thing is its quite a lot of change, I wrote a coccinelle script to do it
> > tree wide, following is the diffstat:
> >  48 files changed, 91 insertions(+), 124 deletions(-)
> > 
> > Imagine then having to add the address argument back in the future in case
> > its ever needed. Is it really worth doing it?
> 
> This is the point. It will get us chance to consider if the optimization
> is still safe.
> 
> And it shouldn't be hard: [partially] revert the commit and get the address
> back into the interface.

I agree with Kirill. This will also remove quite a lot of pointless
code and make it more clear. It is impossible to see what is the address
good for and I couldn't really trace back to commit introducing it to
guess that either. So making sure nobody does anything with it is a good
pre-requisite to make further changes on top.

The chage itself is really interesting, I still have to digest it
completely to see there are no cornercases but from a quick glance it
looks reasonable.
-- 
Michal Hocko
SUSE Labs
