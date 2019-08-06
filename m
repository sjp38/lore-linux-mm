Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B11FC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:47:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3167420818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:47:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="e1W5PQo6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3167420818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CED3C6B0003; Tue,  6 Aug 2019 06:47:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC4C86B0008; Tue,  6 Aug 2019 06:47:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB46B6B000A; Tue,  6 Aug 2019 06:47:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 849D76B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:47:19 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j96so2245236plb.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:47:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=781gQFojuZXlLR9f0Rnz2BsSQ1xNulNQY/lDauCDdSA=;
        b=Pr2HKxLHHEXB9L7IkEAc6NxNKXShOStvINp7Aq680JOROdqzX+0COArw79n1yquNG1
         3nKkf2FX+eRmiV68SEy8KUkqwt66T7yvghlZNzxdr5J1M1G8vYht5YRan055vBM/5n1f
         c08RCuwLXnLT6Akmycx7BJjqqhF+9EsO7wyxaMJETInmPv4TJNLc7biETJROMTuLkv0N
         Uhe7xvXxJhoXt8NDQ00a2ckHFkMHylHC109TrX5Ovqo5IUv0oktln2TAgSa9vu6EVDz5
         fWe3nXtzCzXAH84CPFdjQxqpJObzzl5cqM95d0kKJI3E61ZNb/8h1AWCZZqsLtlObzD4
         a2Bw==
X-Gm-Message-State: APjAAAUZbXTWmQVPfKxDh5nSfQqOxZoWMnpFq8xHEEkVS3hMc+SQl22p
	+R0RfG6CdCVr7i1yC4SeCTTJwQNzfgwHjOnAA4UCFoCakg6tLZNm6YS8id9AHUnpPLvoaGENexK
	7dmwOrS3cszdqsB0WnNmnk9GusgvAIyIFQi2FQNk2zt2pzk4CNQA1J/6go4H9xaG9ew==
X-Received: by 2002:a17:902:4501:: with SMTP id m1mr2558914pld.264.1565088439226;
        Tue, 06 Aug 2019 03:47:19 -0700 (PDT)
X-Received: by 2002:a17:902:4501:: with SMTP id m1mr2558873pld.264.1565088438451;
        Tue, 06 Aug 2019 03:47:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565088438; cv=none;
        d=google.com; s=arc-20160816;
        b=KxGMG43EuDK2i5r2x7GbT+iTdo2qVhyM2BwaMooYgbvy9NVGj6Vcn8E6lgvBt0OfC8
         v6xBAM8kdnERZk+6Bwgw7FTCsySmyYFY2dtBsK0ln05f0+pCWUDvaBrfTxqnVW9JtxWf
         jcbNZ1EiO1WWsboDVPLl0T3jS8vbvsH8TLHcAH+7D1E43PZ1qe56RDOV9Kb37iWX7liQ
         v54nNf7R7yUp/O1QfDPoFJdgLPu7cNJdBr6PwAJGwvSgXr+CjpNCzIoxDnts37YwONSQ
         Xkwok0ImdcNFU3Mxt+xgXw7qMJZKEMCQH4b41uw7EWA+lSjU3cGacU8lrwzvvQMU6lyR
         gyDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=781gQFojuZXlLR9f0Rnz2BsSQ1xNulNQY/lDauCDdSA=;
        b=rkcisf8RnjJ2salM4KfE3AnUa9N59bToOp0Ia5Ou9D/Hwh4b7R2fUQWu7VMPf26gsL
         ZIMzpVMsgzlAq0x8V9DyGJlC36EXaVtpjJLOVwTWzYeMYthH51nrUKk+GtJwlT2nX45q
         vsmsqPhZAahLPn6lr+9fuNJaLruNIyyOG+qoENGBoS5PoPEhDtEB37Y/IqpHxCJcRHrE
         /DX9kZzgo9krUSt01cUHZHtlmZrhnibE/k+2IJESmw97kYM4TlgeDK0pQSnwAu1Loqdi
         kPFsxIzn0Vm9dbw1hfZ/yyh+gNheDFo7RMfHxY0bnE+bvF9zLfYQCXY5uNHFzij86nTu
         me0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=e1W5PQo6;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t6sor102503656plo.20.2019.08.06.03.47.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 03:47:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=e1W5PQo6;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=781gQFojuZXlLR9f0Rnz2BsSQ1xNulNQY/lDauCDdSA=;
        b=e1W5PQo6UI3vE5fsYo9GNTQns85aj/gUpDhLx9+3D64tPpFl02X83oJkMy9XzTBNmf
         x7k9LQX1mYX3Ou3y4IWdZK6NAO3h5S7a8ijztUPEK9VYoOKSdCKcExDxxqYFFPD7vS3L
         s8MA9DjsMd/kXQN1m2atBXnvStSWMRuGddxJk=
X-Google-Smtp-Source: APXvYqyckGHtBm2UKAu71b4v/ySxM/JXAjxm9Txb7Dg6O/cihgtEDSFSoalvYdEzzWgdgOHwA+AgNw==
X-Received: by 2002:a17:902:654f:: with SMTP id d15mr2365106pln.253.1565088438061;
        Tue, 06 Aug 2019 03:47:18 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id a21sm95934459pfi.27.2019.08.06.03.47.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 03:47:17 -0700 (PDT)
Date: Tue, 6 Aug 2019 06:47:15 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
	namhyung@google.com, paulmck@linux.ibm.com,
	Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 1/5] mm/page_idle: Add per-pid idle page tracking
 using virtual indexing
Message-ID: <20190806104715.GC218260@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190806085605.GL11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806085605.GL11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 10:56:05AM +0200, Michal Hocko wrote:
> On Mon 05-08-19 13:04:47, Joel Fernandes (Google) wrote:
> > The page_idle tracking feature currently requires looking up the pagemap
> > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > Looking up PFN from pagemap in Android devices is not supported by
> > unprivileged process and requires SYS_ADMIN and gives 0 for the PFN.
> > 
> > This patch adds support to directly interact with page_idle tracking at
> > the PID level by introducing a /proc/<pid>/page_idle file.  It follows
> > the exact same semantics as the global /sys/kernel/mm/page_idle, but now
> > looking up PFN through pagemap is not needed since the interface uses
> > virtual frame numbers, and at the same time also does not require
> > SYS_ADMIN.
> > 
> > In Android, we are using this for the heap profiler (heapprofd) which
> > profiles and pin points code paths which allocates and leaves memory
> > idle for long periods of time. This method solves the security issue
> > with userspace learning the PFN, and while at it is also shown to yield
> > better results than the pagemap lookup, the theory being that the window
> > where the address space can change is reduced by eliminating the
> > intermediate pagemap look up stage. In virtual address indexing, the
> > process's mmap_sem is held for the duration of the access.
> 
> As already mentioned in one of the previous versions. The interface
> seems sane and the usecase as well. So I do not really have high level
> objections.

That is great to know.

> From a quick look at the patch I would just object to pulling swap idle
> tracking into this patch because it makes the review harder and it is
> essentially a dead code until a later patch. I am also not sure whether
> that is really necessary and it really begs for an explicit
> justification.

Ok I will split it out, and also expand on the need for it a bit more.

> 
> I will try to go through the patch more carefully later as time allows.

Thanks a lot.

> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> -- 
> Michal Hocko
> SUSE Labs

 - Joel

