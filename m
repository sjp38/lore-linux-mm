Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D68DAC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 07:15:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A0C92082E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 07:15:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="SmR0KV6T";
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="t4bQlPkr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A0C92082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 223A66B0005; Fri, 12 Apr 2019 03:15:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D1ED6B000A; Fri, 12 Apr 2019 03:15:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 099376B000C; Fri, 12 Apr 2019 03:15:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC2946B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 03:15:03 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id x66so6379369ywx.1
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 00:15:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Amm2fJ0Ee1oBG0gONpHETd7n25Sgc9oVLeHjNU5GaYs=;
        b=juoBYato2moBmYkMEa0t62hC/BRlGLdYBAD+lnFQJ99Rj/AskMTaBrmrDHqCqVlKGG
         E+wMdO6vkQ21bUb+klh5KwGcLnEsxMt2xaExEw2bn1hYZYAhr9eHxrWR03qPY9WyfXtt
         Um0ZE30bw1E94pWPke8HEvk9rFza/IpEPnqGCLghSAgZvTx1N/7s1mP1uyep0c7zyBJF
         rWffSI/TdnDFEU2HB4Kwqx/qbui+fosDRGCby1ZtnJeRWnbbkvMP3dMBfecsqTka96BT
         jEk5VbYQUtq5FZ6UnIccX92gnaeRaNN9Qwbbrp34ZmmuJqdjNNqOL205OoEt0Ln9xNMz
         g/rw==
X-Gm-Message-State: APjAAAWSaU9ayqYmDkIVJszmiwTA+UxNWvy9/TlofJaGXk+5VyIQ5h2k
	gwA8NvUMu60iMeESTBrbzvMab+D6ph9Fz9BKnZ2VPF4mybrcd9niddP2sfAolPLtGkYN3u5zJCj
	ohch3YhRQJrpka4tPCSkt81/5nFfU2ha1QjkDva/MZHute/X8AhPaoFeQdJO3CdoI4Q==
X-Received: by 2002:a25:a341:: with SMTP id d59mr45594563ybi.426.1555053303525;
        Fri, 12 Apr 2019 00:15:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsOcv2IjBgjJ7YmjRj3jnvSpKtHO5aVFzM15iLy3gueNZHRCUhMI4a3pTk2y9PhUD8JQHQ
X-Received: by 2002:a25:a341:: with SMTP id d59mr45594514ybi.426.1555053302543;
        Fri, 12 Apr 2019 00:15:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555053302; cv=none;
        d=google.com; s=arc-20160816;
        b=MWwfVmo9HfviedvyMrJpvZ0qJBaaPPCzhhJpisjOr02eB6aCDM1pcSDZ4WC8vHZlPM
         yjI7vXz9eIbfniv9OE2SV/InXqu1GAz7QqN0EBkqpIuBaqpy5nsiV/wtv4DeZ3z3uVNW
         LQNYj8I3++BEYMd1i0tK63B1csHVzcLQaikISsUCXZe1caRMY1puFUceKiyXIu0gyybd
         KoOh889LUXV3GiINq/ZefcD3K+QHLX5hcwYoaZU1MWBKQGFGUcy13iSs8hvs3VAI7ph/
         6R3TK5+s6Fgta8PbJGqxOdZLn39w0W9cDD+iaDVL2ODWLd3qd1SI2qqkFKYEC0G4TMP0
         qerg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=Amm2fJ0Ee1oBG0gONpHETd7n25Sgc9oVLeHjNU5GaYs=;
        b=MqThIuo1TnXxd0NPis6BJ4jDmzsBt6p28I3WvJ2Njls1UuOI4AFWYx9+Wpf1iM9fxi
         qQJWMY35MpPmjNn5+RTjWFlfIjo/ROBmb/oXUmEG0AkLf1XZcM+XAFHgjNUu91Hjm2/l
         OV0MZemaXDKh2b7nZkwAZymjGVy4Kq78TVLKvlb/l0mzqEem98f+E7GUxoxgWryqnS2E
         B6z3mmHz7x5+K4DOsPMZPeJqK4eZF/4E26NoWhxxY9pSZ3mYnrMRnQH6p6FDtk5vnU+m
         bHhoFcQkeNSZNtdvoOsdgkswuG+YnBsmxeGqOAJZa685/8Kr01FiNevlUTnQ1GnTS27a
         zaGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=SmR0KV6T;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=t4bQlPkr;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id l21si12816583ybf.206.2019.04.12.00.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 00:15:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=SmR0KV6T;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=t4bQlPkr;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 1F80B8EE0ED;
	Fri, 12 Apr 2019 00:15:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1555053301;
	bh=2BunNTfgNoT1vOgJqr554E2Bpm9yhHNS3FY1WNdiUzA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=SmR0KV6T0/bdBqigVeOQsO3iayUB4/2hFO9gBbRCbFwK6UdZ1EpP6QxL5m9hkbhHD
	 9V5GscqdEx5BAT7pLxKhZBu0FnFgQgN49RnUie73xbwX+2VUmgUZpzgViFM2onb0zd
	 VYvxNY5a0AaA+c1qmiv4c/ny7fLRnOSZAsMXgyAo=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AeXKMzV0d67I; Fri, 12 Apr 2019 00:15:00 -0700 (PDT)
Received: from [10.4.223.204] (unknown [147.83.201.128])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id EF82A8EE0CF;
	Fri, 12 Apr 2019 00:14:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1555053300;
	bh=2BunNTfgNoT1vOgJqr554E2Bpm9yhHNS3FY1WNdiUzA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=t4bQlPkrh/y3auChWG9MleFMd/Wvy6WCvPExpcOBYQMdi5cbmNqfeD6tvdnVDFB/N
	 yAOe6HtK/GN/KM8tmh/7MmLTKToFPYHPiyRKQV47xQZpkLBMOMjxl2ELFklD+Q6ZeZ
	 rxVvrptVJ/NFJC3LH5wJU8BgTIzS+oU67H17SMtE=
Message-ID: <1555053293.3046.4.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Vlastimil Babka <vbabka@suse.cz>, lsf-pc@lists.linux-foundation.org
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>, linux-mm
 <linux-mm@kvack.org>,  linux-block@vger.kernel.org, Michal Hocko
 <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes
 <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, Ming Lei <ming.lei@redhat.com>,
 linux-xfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Dave
 Chinner <david@fromorbit.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Date: Fri, 12 Apr 2019 09:14:53 +0200
In-Reply-To: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
References: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-04-11 at 14:52 +0200, Vlastimil Babka wrote:
> Hi,
> 
> here's a late topic for discussion that came out of my patchset [1].
> It would likely have to involve all three groups, as FS/IO people
> would benefit, but it's MM area.
> 
> Background:
> The recent thread [2] inspired me to look into guaranteeing alignment
> for kmalloc() for power-of-two sizes. IIUC some usecases (see [2])
> don't know the required sizes in advance in order to create named
> caches via kmem_cache_create() with explicit alignment parameter
> (which is the only way to guarantee alignment right now). Moreover,
> in most cases the alignment happens naturally as the slab allocators
> split power-of-two-sized pages into smaller power-of-two-sized
> objects. kmalloc() users then might rely on the alignment even
> unknowingly, until it breaks when e.g. SLUB debugging is enabled.
> 
> Turns out it's not difficult to add the guarantees [1] and in the
> production SLAB/SLUB configurations nothing really changes as
> explained above. Then folks wouldn't have to come up with workarounds
> as in [2]. Technical downsides would be for SLUB debug mode
> (increased memory fragmentation, should be acceptable in a bug
> hunting scenario?), and SLOB (potentially worse performance due to
> increased packing effort, but this slab variant is rather marginal).
> 
> In the session I hope to resolve the question whether this is indeed
> the right thing to do for all kmalloc() users, without an explicit
> alignment requests, and if it's worth the potentially worse
> performance/fragmentation it would impose on a hypothetical new slab
> implementation for which it wouldn't be optimal to split power-of-two
> sized pages into power-of-two-sized objects (or whether there are any
> other downsides).

I think so.  The question is how aligned?  explicit flushing arch's
definitely need at least cache line alignment when using kmalloc for
I/O and if allocations cross cache lines they have serious coherency
problems.   The question of how much more aligned than this is
interesting ... I've got to say that the power of two allocator implies
same alignment as size and we seem to keep growing use cases that
assume this.  I'm not so keen on growing a separate API unless there's
a really useful mm efficiency in breaking the kmalloc alignment
assumptions.

James

