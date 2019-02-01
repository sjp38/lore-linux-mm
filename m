Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDB32C282DB
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 16:12:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EA7121726
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 16:12:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="FJxtzyGW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EA7121726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F0268E0002; Fri,  1 Feb 2019 11:12:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99F988E0001; Fri,  1 Feb 2019 11:12:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88F4F8E0002; Fri,  1 Feb 2019 11:12:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D78C8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 11:12:38 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m37so8454988qte.10
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 08:12:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=quiXn0eW8gENJQ2gJS+neNMOBIo/LLkWdIc48RQXTDM=;
        b=XRlYQTqmvoFTIj68nZqzfcBfkO5MHLqIHyq089mWxL9e0Yb2kVvEg3JrcbaOFx1Dj6
         8AhmB5g1ds6txA9pXhU4YCLRq7USREdxib4oLCXTxzypBYSWDRI2REMo0aeOZJpLD+MS
         aiNjRRPu8oC+SCYpI4vnxuGmwJJWfjtKfQYjNlkwLN6M/+GNNi3wpdhBBTA2L+qSjJIH
         EBaseM+lZA3WQx8PMa2GegIhBAvvArU0fLhA0vdVNQsLqR0CcKBO1bG+ZGidl2hNJjUU
         dgpy3AEJK0M/Eu2FhVYHZSsSruXfhVr4W7d0NbVMW+5L1s972necQLU2gxr1UWVT+TGp
         aAiQ==
X-Gm-Message-State: AJcUukcbuVZMWoHXQ6ebl/rR7yIqQ2p8HjyzSQR1UltdcjoFQDH1F7I8
	PtqUMdpWptNBe9z69u3DlWDAdq3fPKPTkhoasYk7xJLJP+tXGY+rgiEu81UkUEg5ZBpSCudK1o9
	N6IZkViMgekymvII5akqzN13uRr/5b6NnmNcRtlnwSbkLp+Q7Xe3kwfTMLgwD6SY/zJkQypZ65v
	JM4Lh6vFaUCfI+n6KK4ipEtbp/SDvLzLyEMg+0QNlZQNdaIsJMJsJicl33Xs9BjALo8aGtaKWtx
	uTooc2/eig01ZSB50KMIA2r08n4tzsFxQAJodVTXv3NS9tCIPmXrAZGRbTQL1uM82U8FaW2X70l
	J3HIWtKgI1EhGhXOmIxYFfdE8/Il8k7kKLLmbNXm2dTCuXi6md8r5jo0s4tupZr80CC29U4Tba0
	/
X-Received: by 2002:aed:36a9:: with SMTP id f38mr40114598qtb.367.1549037557970;
        Fri, 01 Feb 2019 08:12:37 -0800 (PST)
X-Received: by 2002:aed:36a9:: with SMTP id f38mr40114518qtb.367.1549037556944;
        Fri, 01 Feb 2019 08:12:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549037556; cv=none;
        d=google.com; s=arc-20160816;
        b=AfSHi0mrFKrjTxkP5DZ5kzzwQGkexIfwfZ30oPBgFgWPV/g8aboGrcMkkW3/IPzA16
         VK80B1kJh+kiNZ0EyWZS6965V8fYmcrfBKyE5wuQLriNjQhlP3JYGQrgj1pDxEmQ2dD2
         JQ3LEYiigz5KNRFLbdTNevCpLn4+MIAS3avCv7tzt/oDVZC+F/9PbRNz1PpPjgKY+ZKk
         2736dHQUmw+BVNuvouH43p+aBivY6dTqJiggMYbbSHqPG0gNH8j+z5y9SPKGWp4iHkpg
         MZfqUD0kdOX9DxrJAH4hVabyJpgGxGNO4xcd57FX1jp+S9qyAA5jpUcmdBi7YFWL+5EQ
         SKPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=quiXn0eW8gENJQ2gJS+neNMOBIo/LLkWdIc48RQXTDM=;
        b=WREN6zrAwEXzuk7YdIZIqX2Rvp3cWd7Oq//mOT8JLJwy9L7ovRVrBHk7olvB4bqBD2
         aDpZ0tF8a56TGis/f6T24XoFz69T68ZgqWXHPMcW4p14X3rAAyd27HAhokLyBN7qjzC4
         12nY2656QA7mFdRnLH8gqk07RwDq5MF8K8dPpFNmv3C2GHQH+xoSnW7N+gqvHXSqTZpt
         zOMGzQ4q/ncp1PniSYgj91xU1iErIhHVPSAzZDDQFYqMKtw97X4NJct7uZb0UQs5DJMq
         JS/45mAtKP4FB4nCK0qnlz7MKraBkZ4f+hMDX1Tw0iQfEYnUNk8VARpSTXPHIB27cCtZ
         u/5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=FJxtzyGW;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p54sor10682114qta.37.2019.02.01.08.12.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Feb 2019 08:12:35 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=FJxtzyGW;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=quiXn0eW8gENJQ2gJS+neNMOBIo/LLkWdIc48RQXTDM=;
        b=FJxtzyGWgskESR2k9L9isn828AO09+N+HuP3nAaDzFlbGiyI3IkRb+dI95b+qwHsFp
         taGu2/RGTS5RRJ9/Z5NiCbZDursEgcB8TqiiadpPycaR3JpyIY/J9RMNC4UvQwNXYEO6
         fCCT/0zdkELpkSqG/BBHYrSARXYUo/vOIfTH36h9Q2RSZ8lpWN7hgHmn0S0j57ey5ZCU
         IfzwwodbNPzWByHoHSoMWYAg2iOdSzGq83AW/VX9T99e5J6YTDt6Y1qyPudl/hw+d9N3
         aqkMde8RGGcBdEvy/8yMKeq3OfF0pJoavBeMkjiczMWFwZZ9wm9xKrgSQHxuAie9R+5k
         3LNg==
X-Google-Smtp-Source: ALg8bN6Xhm8+Dphexj9jdruWmgqh9zBeGrQhRUyClmtGuM2tr8dcjMyszXKsoOq+aWfpv3IWb5Y1gw==
X-Received: by 2002:ac8:2ca9:: with SMTP id 38mr40275308qtw.338.1549037555283;
        Fri, 01 Feb 2019 08:12:35 -0800 (PST)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id s9sm9706606qta.35.2019.02.01.08.12.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Feb 2019 08:12:34 -0800 (PST)
Date: Fri, 1 Feb 2019 11:12:33 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH] mm: Throttle allocators when failing reclaim over
 memory.high
Message-ID: <20190201161233.GA11231@cmpxchg.org>
References: <20190201011352.GA14370@chrisdown.name>
 <20190201071757.GE11599@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201071757.GE11599@dhcp22.suse.cz>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 08:17:57AM +0100, Michal Hocko wrote:
> On Thu 31-01-19 20:13:52, Chris Down wrote:
> [...]
> > The current situation goes against both the expectations of users of
> > memory.high, and our intentions as cgroup v2 developers. In
> > cgroup-v2.txt, we claim that we will throttle and only under "extreme
> > conditions" will memory.high protection be breached. Likewise, cgroup v2
> > users generally also expect that memory.high should throttle workloads
> > as they exceed their high threshold. However, as seen above, this isn't
> > always how it works in practice -- even on banal setups like those with
> > no swap, or where swap has become exhausted, we can end up with
> > memory.high being breached and us having no weapons left in our arsenal
> > to combat runaway growth with, since reclaim is futile.
> > 
> > It's also hard for system monitoring software or users to tell how bad
> > the situation is, as "high" events for the memcg may in some cases be
> > benign, and in others be catastrophic. The current status quo is that we
> > fail containment in a way that doesn't provide any advance warning that
> > things are about to go horribly wrong (for example, we are about to
> > invoke the kernel OOM killer).
> > 
> > This patch introduces explicit throttling when reclaim is failing to
> > keep memcg size contained at the memory.high setting. It does so by
> > applying an exponential delay curve derived from the memcg's overage
> > compared to memory.high.  In the normal case where the memcg is either
> > below or only marginally over its memory.high setting, no throttling
> > will be performed.
> 
> How does this play wit the actual OOM when the user expects oom to
> resolve the situation because the reclaim is futile and there is nothing
> reclaimable except for killing a process?

Hm, can you elaborate on your question a bit?

The idea behind memory.high is to throttle allocations long enough for
the admin or a management daemon to intervene, but not to trigger the
kernel oom killer. It was designed as a replacement for the cgroup1
oom_control, but without the deadlock potential, ptrace problems etc.

What we specifically do is to set memory.high and have a daemon (oomd)
watch memory.pressure, io.pressure etc. in the group. If pressure
exceeds a certain threshold, the daemon kills something.

As you know, the kernel OOM killer does not kick in reliably when
e.g. page cache is thrashing heavily, since from a kernel POV it's
still successfully allocating and reclaiming - meanwhile the workload
is spending most its time in page faults. And when the kernel OOM
killer does kick in, its selection policy is not very workload-aware.

This daemon on the other hand can be configured to 1) kick in reliably
when the workload-specific tolerances for slowdowns and latencies are
violated (which tends to be way earlier than the kernel oom killer
usually kicks in) and 2) know about the workload and all its
components to make an informed kill decision.

Right now, that throttling mechanism works okay with swap enabled, but
we cannot enable swap everywhere, or sometimes run out of swap, and
then it breaks down and we run into system OOMs.

This patch makes sure memory.high *always* implements the throttling
semantics described in cgroup-v2.txt, not just most of the time.

