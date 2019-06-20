Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A943C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:32:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D4A6206E0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:32:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ttF/SnGY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D4A6206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C96756B0005; Thu, 20 Jun 2019 06:32:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C46ED8E0002; Thu, 20 Jun 2019 06:32:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B36988E0001; Thu, 20 Jun 2019 06:32:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE8C6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:32:24 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so1706988pfb.21
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:32:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Vh/TaWAXivsCSm93ZkOvEDBkx2UKyyCx6lOeAnqGOlE=;
        b=nm60lPm3tCynac3If0rdOQD0BzH8LYYWtKNS8RS0BzZdmvz4fEIcrTc84GZX1VYx8Q
         y1ItQjXaSI2oEsI5OmBovbbOdlWkPVWE8qmBOk2edSfRJKXJ5ZXI5EIdzGyp59ilfCud
         8+BuoiGRNrchr+8cY+3iEcFihmAksmtUoBLB7IUPFR91KZQtkFVvftZs3Fz2kMDQxhYr
         /x/puIeX2xpAVtBD0zYst9I7WJ1DCnmm9LUyTxmzzBtLf/c8thn5flYWdOoiv8sgGc8S
         jZEArnpna9NfJ9H+RvqS4PZMv2ZhCOWfMLw4Jt4mgHvLsmxAwog3rDOpCYYEjm4CwB0N
         BLOg==
X-Gm-Message-State: APjAAAVoZUgP60pqcqOCjvQp2rHDK7ak9z7/5NFArsZKg8+KtByMlgUq
	MPa92vpk7nXkQf/rGqi3YFrp7yH00t7K+TchfyVfGhbVS1YmyU9T5fdpCn0SfomQn8+riB37zEQ
	RH9hJ4l2zEcCVAZq+hxWadJRi5cY912UVwkSW0eKdqNjrCL+d/XJyHmeV0cj7a7Q=
X-Received: by 2002:a17:902:28c9:: with SMTP id f67mr125572104plb.19.1561026743986;
        Thu, 20 Jun 2019 03:32:23 -0700 (PDT)
X-Received: by 2002:a17:902:28c9:: with SMTP id f67mr125572054plb.19.1561026743248;
        Thu, 20 Jun 2019 03:32:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561026743; cv=none;
        d=google.com; s=arc-20160816;
        b=MygijxpgFA8optTRP/flom2fYHO18lyV8YhPEjevg4XmLKuzelcRaeaX+X+FvyrgY+
         h/Num8tjlSn0zVfWb9OywLPAj+l54NSZ0Xl1culzSXW0InfxTvW+tyvfWOEAI+Wl9Jpj
         1L2eoApB+t0cErnf8hhcNXRi51KgwsP6EioQgc4hBa73mCQU/wDaXrEJCOcCSYfLCKeb
         wHIp6yD6mHqcukMU3kKuv4rDIqLeg/pu2O9W5xFoCyU1MzzI/anldlYV7zDSStI38Z79
         5uIOgloBIfobCTRW1r9GM9o2ikSxxUt9XzDBxC/r/U1bHmIOetyZgKRo4dgZTeNHs4n9
         MpQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=Vh/TaWAXivsCSm93ZkOvEDBkx2UKyyCx6lOeAnqGOlE=;
        b=HC2yOtKUpur8lL3BXKcNoTR9I1Q7t5DvSbT/GCxTPLiPB8/dQNROvLZ/ezoYkLuWI5
         yY+S/PFKvsnRhGn9M2UAd3JV8+uLldVqBncDIH3qnATiYo5R5MHAbUigU6I/WY95uONm
         yaHOhd31ZRXHkq9VguR7UDxQNjqf25xQmIBmlZZ46XSeQpLNUooBJ8cVNl0N5sJ/68Ym
         eC7iAbEV1CtzxSDl7udLlNExlD86LeF2UJ26aNoQY1Ek+ADxxAsSw3Jvhte8S/go9Olu
         qLOss7rZJW7Fp/j32rXJNNviXRDNL8tauh7uYgs+wyD9tiNQPA6SjNT8n7ahdsL63tC/
         q/TA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ttF/SnGY";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 77sor20481748pfy.26.2019.06.20.03.32.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 03:32:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ttF/SnGY";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Vh/TaWAXivsCSm93ZkOvEDBkx2UKyyCx6lOeAnqGOlE=;
        b=ttF/SnGYG3MOm+YgtgBbYEgYcC3Gryeob5F0AgH9pKO3BZ4CD/56pVCkDIFxyQBGnJ
         vNodJ0g4aVQaCP6EaAGUeJY4lkffwXbWCXY68CjsUqSHCBAiAuab7MFHcHqwsatieGZ/
         nYHo33JOSHtedVBSCYVCfNsAMCaDihPzCFYwRPUZDvjFhv1MN0GcPnaiTSpTH1xgHIYn
         tqu9zrsbTkMcFADzh3sHS5xHtVOW2Jfsd6SQL+SxKAix+d8k8hOq9KsmgMZEIPp/xKXy
         oe32UVSZTA6hZKSfi0QIXidVgJrfAoU4o67stK283mjbTtEtY6VrboiGudu85+RMdB8r
         ClnA==
X-Google-Smtp-Source: APXvYqzG+Ny73nTkuvycxB2Qtw2No/JfB1pM/xIlj0jTTPw8WMCkRlsju9l456JNXOtmVU5qfE89Vw==
X-Received: by 2002:a63:d008:: with SMTP id z8mr12308782pgf.335.1561026742731;
        Thu, 20 Jun 2019 03:32:22 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id 12sm21098259pfi.60.2019.06.20.03.32.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 20 Jun 2019 03:32:21 -0700 (PDT)
Date: Thu, 20 Jun 2019 19:32:15 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190620103215.GF105727@google.com>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-5-minchan@kernel.org>
 <20190619132450.GQ2968@dhcp22.suse.cz>
 <20190620041620.GB105727@google.com>
 <20190620070444.GB12083@dhcp22.suse.cz>
 <20190620084040.GD105727@google.com>
 <20190620092209.GD12083@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620092209.GD12083@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 11:22:09AM +0200, Michal Hocko wrote:
> On Thu 20-06-19 17:40:40, Minchan Kim wrote:
> > > > > Pushing out a shared page cache
> > > > > is possible even now but this interface gives a much easier tool to
> > > > > evict shared state and perform all sorts of timing attacks. Unless I am
> > > > > missing something we should be doing something similar to mincore and
> > > > > ignore shared pages without a writeable access or at least document why
> > > > > we do not care.
> > > > 
> > > > I'm not sure IIUC side channel attach. As you mentioned, without this syscall,
> > > > 1. they already can do that simply by memory hogging
> > > 
> > > This is way much more harder for practical attacks because the reclaim
> > > logic is not fully under the attackers control. Having a direct tool to
> > > reclaim memory directly then just opens doors to measure the other
> > > consumers of that memory and all sorts of side channel.
> > 
> > Not sure it's much more harder. It's really easy on my experience.
> > Just creating new memory hogger and consume memory step by step until
> > you newly allocated pages will be reclaimed.
> 
> You can contain an untrusted application into a memcg and it will only
> reclaim its own working set.
> 
> > > > 2. If we need fix MADV_PAGEOUT, that means we need to fix MADV_DONTNEED, too?
> > > 
> > > nope because MADV_DONTNEED doesn't unmap from other processes.
> > 
> > Hmm, I don't understand. MADV_PAGEOUT doesn't unmap from other
> > processes, either.
> 
> Either I am confused or missing something. shrink_page_list does
> try_to_unmap and that unmaps from all processes, right?

You don't miss it. It seems now I undetstand what you pointed out.
What you meant is attacker can see what page was faulting-in from other processes
via measuring access delay from his address space and MADV_PAGEOUT makes it more
easiler. Thus, it's an issue regardless of recent mincore fix. Right?
Then, okay, I will add can_do_mincore similar check for the MADV_PAGEOUT syscall
if others have different ideas.

Thanks.

