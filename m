Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2671DC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:26:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD287216B7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:26:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d/JcV1xu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD287216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AE3C6B0003; Tue, 21 May 2019 06:26:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15F0D6B0005; Tue, 21 May 2019 06:26:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04E406B0006; Tue, 21 May 2019 06:26:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD9096B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:26:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x5so12075621pfi.5
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:26:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=v7oTWqJm+U+8EwWIlN8PXARmqW1yabluA4GVB5Q/Ymc=;
        b=eV5kGr21Dnq3qEichdUIsi04OtUO1tN8dnuEwR/QDAqSU3mfhI6hec0mx0Q02XbwNG
         CnXR8U+5crUdDdDGcVg5hmc5cMXKGjAjErTtCiJhKndeXgIQqc3YoeLWAAhG1fHOv/1T
         BBpDDEw5uceSZRFIY+EkcI6JYaBp2brzqlhupSM34RSjMBhoJxKZ7gQIuNxO61CY/c7X
         lLdRVsD9b2rNgiGQaIN2dEtwPGAO5trWOL92thsrN6R2oH79+NlcTH1b8O2ypVG+LlDp
         zU3/IBD1/TKMR5xo5a6dFksYivZntZUehNXClezksxZw4sl2nlWAHPRE5msdtggdLiWN
         eNcA==
X-Gm-Message-State: APjAAAVztXqEGWXTZyv9c2WfxGMo8HMBmpSql8hNME1M1sHUgxeqkvCc
	GNoOgW+tx99e2QDHMOsV6QPOah5XV7IaCE1mFBJSGcyuQZ/RK1EIvgw8MLsbgWCm8Bfag2aVZVe
	Bohn9T52QDDm1E81LDjG+PC7QX4jimhI2MvOX6YZDV3ci3JEEDvEeN9o/34NX2Fo=
X-Received: by 2002:a63:950d:: with SMTP id p13mr81616904pgd.269.1558434381326;
        Tue, 21 May 2019 03:26:21 -0700 (PDT)
X-Received: by 2002:a63:950d:: with SMTP id p13mr81616827pgd.269.1558434380397;
        Tue, 21 May 2019 03:26:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558434380; cv=none;
        d=google.com; s=arc-20160816;
        b=mqoArPcLrOyMhiAa6omhJh/PKjfJh/QrQVDRLo4dtWzO8mSodq00xA5ZQwejhNzi6R
         TkXwdVGUDUlEtnMsMeWHqgln/B/PWZkoIU/xruk6EGvesAXuZXFR3WnSFjnoFkKw56o1
         2JarXzIkXc0TxxKSw9j3ATA9GL6Klcm50gAoMXLKpHj6cn4GFKSpFRulATbAGYqQnReO
         9UVFVH8DjcU8M+TG2jmBd/XUvLv+V2wlIK3rDAzDFe8cY9mv1Gj5thKDf+3492ekIdy3
         1wdTxzAbp2qXUN9dyEVFHv4YTX4UMppDPPxnfcgySZJhNpPMItjq7YCFRaMveJelVD5T
         cdHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=v7oTWqJm+U+8EwWIlN8PXARmqW1yabluA4GVB5Q/Ymc=;
        b=SdSi/GPgIYoic0pde5KJ7zXUH5UrE75rP84eMTel9tCInFp+rESqVUisCZWgHlPPDu
         OpcrnKhMggc5c5ljHG3OTeSOmoDuJljNQyMBxAYwjbC3PxWaDdKSmXFdypgqww+EOL92
         Ea5Qgnf8qN96GlEYCBbybPG37Xk9SdWf7bkm3XmsrZhVS8cS9YOo7ZHRg5oakOvRE3Q1
         fbtJOZwss7FEIPRseDPhzx2InxM05PJmAlzY9fjGGTnx8BLN6hEkTnVU5RIL2yj3g9MT
         X1dWZMJhtLi3MSLCm/4wPaaxWQM4bp0G0hQBFkiRL/2fdNkTSIdjUlK6XvBovraYQGmV
         A2gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="d/JcV1xu";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor2177182pgs.22.2019.05.21.03.26.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 03:26:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="d/JcV1xu";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=v7oTWqJm+U+8EwWIlN8PXARmqW1yabluA4GVB5Q/Ymc=;
        b=d/JcV1xuIxQEiJwk7yG4v/8OtBPTzjRoH8pRp+ELNSATolCfDK10qD/aK35UikxFIH
         XeQP6Deb0NOJGW9tREokTHWw5iFX8kZxVfgFeb/CCvMv2F9O3egSSZNvvB7f2WZlGxbI
         u80t7LgdQY+wj3uWSQsxNk9jKK9aZiyNeusSuazL9BtuzJEfWCE2KkS4J0qf++Sxcpyy
         m1IVjgGh1hp9/6t4cp2N7Lpabf829ZtUVbTkGefGfgmPgYsZ8w6H0HNRrKvWjWordBwS
         lwFekyCyWpBkKcRcnAHRnL9rPS9xJITzC59oT29L99JwuLJ/c2TsdbdElO5uRbjpqpiI
         R+4A==
X-Google-Smtp-Source: APXvYqzZdjlSTwRjqi+DHWVHAtfu7VOytFN2Av0aQnixHQc7zc41tJwI2PuEyhis7/e/9mFRwgfs2w==
X-Received: by 2002:a63:754b:: with SMTP id f11mr81175818pgn.32.1558434379902;
        Tue, 21 May 2019 03:26:19 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id z7sm26834601pfr.23.2019.05.21.03.26.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 03:26:18 -0700 (PDT)
Date: Tue, 21 May 2019 19:26:13 +0900
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
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190521102613.GC219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz>
 <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521062421.GD32329@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > [Cc linux-api]
> > > 
> > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > Currently, process_madvise syscall works for only one address range
> > > > so user should call the syscall several times to give hints to
> > > > multiple address range.
> > > 
> > > Is that a problem? How big of a problem? Any numbers?
> > 
> > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > with number in the description at respin.
> 
> Does this really have to be a fast operation? I would expect the monitor
> is by no means a fast path. The system call overhead is not what it used
> to be, sigh, but still for something that is not a hot path it should be
> tolerable, especially when the whole operation is quite expensive on its
> own (wrt. the syscall entry/exit).

What's different with process_vm_[readv|writev] and vmsplice?
If the range needed to be covered is a lot, vector operation makes senese
to me.

> 
> I am not saying we do not need a multiplexing API, I am just not sure
> we need it right away. Btw. there was some demand for other MM syscalls
> to provide a multiplexing API (e.g. mprotect), maybe it would be better
> to handle those in one go?

That's the exactly what Daniel Colascione suggested from internal
review. That would be a interesting approach if we could aggregate
all of system call in one go.

> -- 
> Michal Hocko
> SUSE Labs

