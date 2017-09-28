Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9C4B6B0266
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 10:53:07 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o77so1852050qke.1
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 07:53:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 17sor477628qkt.102.2017.09.28.07.53.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 07:53:05 -0700 (PDT)
Date: Thu, 28 Sep 2017 07:53:02 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: EBPF-triggered WARNING at mm/percpu.c:1361 in v4-14-rc2
Message-ID: <20170928145302.GE15129@devbig577.frc2.facebook.com>
References: <20170928112727.GA11310@leverpostej>
 <59CD093A.6030201@iogearbox.net>
 <20170928144538.GA32487@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170928144538.GA32487@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, syzkaller@googlegroups.com, "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, Christoph Lameter <cl@linux.com>

Hello,

On Thu, Sep 28, 2017 at 03:45:38PM +0100, Mark Rutland wrote:
> > Perhaps the pr_warn() should be ratelimited; or could there be an
> > option where we only return NULL, not triggering a warn at all (which
> > would likely be what callers might do anyway when checking against
> > PCPU_MIN_UNIT_SIZE and then bailing out)?
> 
> Those both make sense to me; checking __GFP_NOWARN should be easy
> enough.

That also makes sense.

> Just to check, do you think that dev_map_alloc() should explicitly test
> the size against PCPU_MIN_UNIT_SIZE, prior to calling pcpu_alloc()?

But let's please not do this.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
