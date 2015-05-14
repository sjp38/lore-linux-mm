Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 53B6B6B0072
	for <linux-mm@kvack.org>; Thu, 14 May 2015 10:30:42 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so19136062wic.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 07:30:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g7si38939500wjy.213.2015.05.14.07.30.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 07:30:41 -0700 (PDT)
Date: Thu, 14 May 2015 16:30:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514143039.GI6799@dhcp22.suse.cz>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514103148.GA5066@rei.suse.de>
 <20150514115641.GE6799@dhcp22.suse.cz>
 <20150514120142.GG5066@rei.suse.de>
 <20150514121248.GG6799@dhcp22.suse.cz>
 <20150514123816.GC6993@rei>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514123816.GC6993@rei>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Nikolay Borisov <kernel@kyup.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 14-05-15 14:38:16, Cyril Hrubis wrote:
> Hi!
> > > Then please send a patch to remove the test.
> > 
> > I think we can still fix both tescases and expect not to fail with
> > regular mmap but fail it with unreclaimable memory (e.g. disallow
> > swapout or use mlock).
> 
> That sounds even better.

untested patch below:
---
