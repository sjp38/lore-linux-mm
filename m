Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9CE16B02C3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 13:12:47 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f207so26102511qke.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 10:12:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k90si3715096qkh.150.2017.08.17.10.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 10:12:45 -0700 (PDT)
Date: Thu, 17 Aug 2017 19:12:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: +
 mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently.patch added to
 -mm tree
Message-ID: <20170817171240.GB5066@redhat.com>
References: <59936823.CQNWQErWJ8EAIG3q%akpm@linux-foundation.org>
 <20170816132329.GA32169@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816132329.GA32169@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hughd@google.com, kirill@shutemov.name, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 16, 2017 at 03:23:29PM +0200, Michal Hocko wrote:
> Reviewed-by: Michal Hocko <mhocko@suse.com>

Thanks for the review!

There's this further possible microoptimization that can be folded on top.
