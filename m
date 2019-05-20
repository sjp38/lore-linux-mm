Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9503C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 975C921479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:55:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HU8isgRW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 975C921479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 317726B0006; Mon, 20 May 2019 18:55:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C7286B0007; Mon, 20 May 2019 18:55:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B6686B0008; Mon, 20 May 2019 18:55:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D5CBC6B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 18:55:42 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so10001455plt.11
        for <linux-mm@kvack.org>; Mon, 20 May 2019 15:55:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BjbgkbeOHTGhsjCy7OuxJHMPPkUmdjz23iAfUR7ljPg=;
        b=fzwhnbWr6/7kWBwFsqP/RTfLeJCoEdR9RRwLZEykFgPXmb3QLBdK5XA4VCxhwp/vp8
         sxsCquCM99Ts8yArXzRfy7I/o65xbL4awCrzrhfnicovVpOVawEsGhG0mRZOq8Vcdh72
         kIvUd4D68PapAaHLE8nfjSvbE6eeeVPfPZxGBqL4WngOZSwaMNEyos2gnvxIThfpzojU
         y/o3wldv7zwJ+1GNVquMccCUUCP2PPHFIV5u1ep8buPBVPP6kF2EL3BuSpF3zsuWNv8C
         hk3AIyNufq5pO9j7fp3oZHIf5Zfj7qQkPWY6GrC4jgNXvXvwp8fwi1/54VVt0sj2OaEH
         r8sQ==
X-Gm-Message-State: APjAAAUaqLEN0+C7/fGMA0VmK4Ur64qbHSB+VflsQSsLeTTTJ1KlWPU8
	Sco2X22a6ZNPSin0jDStkOx9MlhGEzsggGWGosHrRRXKhSjZtqbntSaBKzvxzOdqqgAddIbBwaU
	afdDWrmL99w9ZfbPh8aXpsI+bwd5M71yDqI63Hn9VqWZzoom1lU2uZAgZacQlhB8=
X-Received: by 2002:a62:86ce:: with SMTP id x197mr83360965pfd.218.1558392942527;
        Mon, 20 May 2019 15:55:42 -0700 (PDT)
X-Received: by 2002:a62:86ce:: with SMTP id x197mr83360922pfd.218.1558392941972;
        Mon, 20 May 2019 15:55:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558392941; cv=none;
        d=google.com; s=arc-20160816;
        b=l7erhzfu6p2EMpVzC3WyD7uRATSUN76mSKZqgVDdSPuUdfj6bGhGjXBCM2i6sq22QV
         o98TeZsfBZMOP4qqIxOFa7uPJBLKpR2BqLpG5YNwjEu9STywCcHsEhG8BZyej6iT4Xmj
         itkdNRPgHKQ/+8dndS8uvcYn9Qz8+AL2OlQdh1cxmZ8nov6+1q+Ldiy/vZjsQZ6PCKi8
         XhcNKFI2YVG8PE8QtDSk5xTY9h1hUN+tn4PaTFj+JSVcMG2WjyKtX5gOFz2cjy58hzJD
         JxRTqDUX8PX3JqtJE+j5H5GC7ioStHvJjTiLaoiYaMWtxbssA7PTVtH74OZGG0jbTREM
         kIxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=BjbgkbeOHTGhsjCy7OuxJHMPPkUmdjz23iAfUR7ljPg=;
        b=H3DA/g1qjC8NAHlsNJ5d64NdD3EgTNOegKNLmTAv3DVC94e03aGEZlREL61rTbEs3a
         2Lr5CTCVkxLQOs9biKLeygmTw5mDdt1NVbNq+/ukPeAjqsJyG6omgiiXOD0gOMUsG2uS
         aGdO6wuBnQr/vx7nNsXqUA3FfmASYIT05UUA5qGzH9TA37osVRLo85uWrj/VZHiI3IjB
         yUckliIQyDjwi8ot2f42vN0w08XPk1agJYWYfgCnT/+NQJIUMSn1t9TyZMng7mMuMW5M
         HiNaGkVbWhGqyzRiU6kQltk3uixqXQWAAQBu4mR5D5m1/Dz6s9WvJC1Quyh1CeyNawPh
         VWVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HU8isgRW;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s3sor20646922plb.48.2019.05.20.15.55.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 15:55:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HU8isgRW;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BjbgkbeOHTGhsjCy7OuxJHMPPkUmdjz23iAfUR7ljPg=;
        b=HU8isgRW3uguKD67qSirZnoX4T/2EhG93h+rxlkXP9HrUQdNZlN3JzqdO53jOxACQZ
         TpDriJVeoXal6/RRj+iro8d4y7zPjtd81wCOX6ryGb0T7YFUXT4YcH7hKeMxQ/bMNEU5
         uo3j1EWgLO7v17RGewOfi7a3lq70dv/VQTvYaqf8DaM3H/2gi8+4rk6VaoSrPk1tydkC
         LFOis+L8NAFZ/HXut1M1Yh65814eJVhO2rQvRJuMsnS2LuZZQr9aJMFvycEO3o5oBbwE
         WWFn7i54Xv2t8aDBLGQbW9T+w4Nn2kL/1MYzJc2IS0KHkCE2y9YcwDkUPdiZrBmGfKT7
         SXvw==
X-Google-Smtp-Source: APXvYqxJcDWonzZ2CUXr8a8hGMt9fD1MNq+9Q9WdoNmZaquGBn5NDx28goXyWcXD3JYa+LYamNjjvg==
X-Received: by 2002:a17:902:2de4:: with SMTP id p91mr61953894plb.300.1558392941633;
        Mon, 20 May 2019 15:55:41 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id k3sm25292163pfa.36.2019.05.20.15.55.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 15:55:40 -0700 (PDT)
Date: Tue, 21 May 2019 07:55:34 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Message-ID: <20190520225534.GB10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-2-minchan@kernel.org>
 <20190520081621.GV6836@dhcp22.suse.cz>
 <20190520081943.GW6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520081943.GW6836@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 10:19:43AM +0200, Michal Hocko wrote:
> On Mon 20-05-19 10:16:21, Michal Hocko wrote:
> > [CC linux-api]
> > 
> > On Mon 20-05-19 12:52:48, Minchan Kim wrote:
> > > When a process expects no accesses to a certain memory range
> > > it could hint kernel that the pages can be reclaimed
> > > when memory pressure happens but data should be preserved
> > > for future use.  This could reduce workingset eviction so it
> > > ends up increasing performance.
> > > 
> > > This patch introduces the new MADV_COOL hint to madvise(2)
> > > syscall. MADV_COOL can be used by a process to mark a memory range
> > > as not expected to be used in the near future. The hint can help
> > > kernel in deciding which pages to evict early during memory
> > > pressure.
> > 
> > I do not want to start naming fight but MADV_COOL sounds a bit
> > misleading. Everybody thinks his pages are cool ;). Probably MADV_COLD
> > or MADV_DONTNEED_PRESERVE.
> 
> OK, I can see that you have used MADV_COLD for a different mode.
> So this one is effectively a non destructive MADV_FREE alternative
> so MADV_FREE_PRESERVE would sound like a good fit. Your MADV_COLD
> in other patch would then be MADV_DONTNEED_PRESERVE. Right?

Correct.

