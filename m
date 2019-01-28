Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E087C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:42:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B88C72177E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:42:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="QWvsOqRq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B88C72177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58D888E0003; Mon, 28 Jan 2019 16:42:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53DD98E0001; Mon, 28 Jan 2019 16:42:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42BF58E0003; Mon, 28 Jan 2019 16:42:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6E38E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:42:17 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id k69so10184288ywa.12
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:42:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=a9PsKmGgPsTKkLBb3g/jY5/HxZPgchB4hPGH18bC0Lo=;
        b=tkL/jgwugVjwqJPCMbYQv4jG1JSEIov/sNkP5AE/wh+UJRQeSiUFtmbcDGQ3cQAfcT
         ilXjQI+boY4CmRB7eGEdC1FeR8aCVceXQ84nV0m/f0fM5bbjhSedRDYilr0r0VaJQxPK
         aX0JV9tAugBiPOMi9I0dB8MyDDef8BICtG4zGVVB3KRhXNez1AbbMw2/ATAf+gc6mjGD
         0Ihtygu/NLSRpL1zEyG/GGvTYUbqieO24nvP8noi3aI/MPQOvzKeVkcfZzAZNgdPciYG
         VCcvhCt/URt5sYXe1HWcli5M72QCSYsHxPRzzlULuqtJWbFvLnBJoWbRRFiwKEjhHH1E
         jfYQ==
X-Gm-Message-State: AHQUAubpZptfNQyW6MoYOX4HzdxVspDIqmnU9kf6wQM8OwXNa7j+y3ie
	Re8Cxh7p8k5qsK2M5C83Ys+DX6xZwpjfB04Oq0XyrIR+aOSalsljp/xA8HOlaN5wdwHu5QiBwzb
	CXkhuUYmrlFHwj5CTpIn7uuexVD2tm6vt4MNTxPneGGpGcAldXlZa0i+m2L9S+w81nIA8sKN0Es
	KSOxIQVYA2zWb5jFHe/6rC4DO5uea6rhrvk8Y+xfM1MIcl+zqLyTUn2xtfzUznOqZTB+nG3tWja
	OT3WVSFKgGPchOZYvlG3b2hZycstVSfU2bqucBUxvDxnRPBlLKz7eblYf3ReO8e3z6LHfuU72WL
	dIfI2CfcTfYdICkhpIVMgpFeOOI5VO3K0M0+jNGaiHH1K1sDiVha2abHttCi9JtQ0a7MCWMmsCO
	9
X-Received: by 2002:a25:cc8a:: with SMTP id l132mr9789488ybf.29.1548711736825;
        Mon, 28 Jan 2019 13:42:16 -0800 (PST)
X-Received: by 2002:a25:cc8a:: with SMTP id l132mr9789457ybf.29.1548711736236;
        Mon, 28 Jan 2019 13:42:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548711736; cv=none;
        d=google.com; s=arc-20160816;
        b=Nu6UzKp8LrcH7zi/XH/uJ57bo5Lm58vcbhZH0kuTfqm44ozX2/HMlHyDTHDrAovfY6
         VK3/KWE78JopLNMbfFH8JgV971JhWPulHUx38x8eh1odCdT+BhdtABgwMC00bfhr9vVy
         R4H8ZnGoBB1bOqWDkpNQBJQzn/AdPnmIo/Jo2GPaY2eIJUqy0xICOIZ/dTiSyP2nqo4h
         Tjy+uTNKyyQ0bxxcAY/tQxyU4THE8UmFxUn1sfBv227YHLNB5T3nimGUfobN4qWnOrW1
         SwwUIeRndaYuNpOgIsdoeXfLgdE0IJfrjiDLUfbqmJkmokVhUkmNONCS5mhDunxFeog/
         s7yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=a9PsKmGgPsTKkLBb3g/jY5/HxZPgchB4hPGH18bC0Lo=;
        b=zsgdyiKKtFL6rnDqUDn6NQogTSyLXu2Zof7L6M4V18oDZFxVxmFYBDPihSSMDA1YLr
         Xs0M8F21QpM2i8JdezlVIv1kEaZhKmt+xnXY131c7SOEeE9jzpuZ3pVtGp/AjRyRrORu
         g7+T5YloIHWWiv92u477BMijBWLOgdT2IpuJ51FNcV6clWGJmf5uAPmYK/gBkqwMjU2r
         RfJYxgpjKSkFyAQEW/hdQiavmTPEW4ELkYHarWiUjtlnvU+2jen0CtGUsM6K8HAf2uVP
         4tEHXZ9ruKJV5+R1pGIxHnog134yz+Xq83zC2mxZTtBNZ6wvDJHBGpqv2euqfGSdNNgt
         3T3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=QWvsOqRq;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y127sor4500814ywf.195.2019.01.28.13.42.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 13:42:16 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=QWvsOqRq;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=a9PsKmGgPsTKkLBb3g/jY5/HxZPgchB4hPGH18bC0Lo=;
        b=QWvsOqRqyIcKZR7jItEvBi0genFdYcFV76xiW7vN4DO4Eba+BvzpUc474b40EBe4es
         h4O385MUeLovYQGLyM9wvEI2R3H0Lshq64jenrQ1csimCipZwR+Ux6IUPGUTgHM8Jw5f
         0a2oM0SqHJFVbknYw26SZ8N4D2DVfzvcaDunk=
X-Google-Smtp-Source: ALg8bN7ixIYyq/jqwUusdxnjFTjdORjTiX7RCaORCK6XnS2wV8OmW/M/daK2UKZbt4qlEjcxYyGVhw==
X-Received: by 2002:a81:87c3:: with SMTP id x186mr22526821ywf.147.1548711735622;
        Mon, 28 Jan 2019 13:42:15 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:aa7d])
        by smtp.gmail.com with ESMTPSA id f10sm19386715ywb.26.2019.01.28.13.42.14
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 28 Jan 2019 13:42:14 -0800 (PST)
Date: Mon, 28 Jan 2019 16:42:13 -0500
From: Chris Down <chris@chrisdown.name>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Dennis Zhou <dennis@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: Proportional memory.{low,min} reclaim
Message-ID: <20190128214213.GB15349@chrisdown.name>
References: <20190124014455.GA6396@chrisdown.name>
 <20190128210031.GA31446@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190128210031.GA31446@castle.DHCP.thefacebook.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Roman Gushchin writes:
>Hm, it looks a bit suspicious to me.
>
>Let's say memory.low = 3G, memory.min = 1G and memory.current = 2G.
>cgroup_size / protection == 1, so scan doesn't depend on memory.min at all.
>
>So, we need to look directly at memory.emin in memcg_low_reclaim case, and
>ignore memory.(e)low.

Hmm, this isn't really a common situation that I'd thought about, but it seems 
reasonable to make the boundaries when in low reclaim to be between min and 
low, rather than 0 and low. I'll add another patch with that. Thanks

>> +			scan = clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);
>
>Idk, how much sense does it have to make it larger than SWAP_CLUSTER_MAX,
>given that it will become 0 on default (and almost any other) priority.

In my testing, setting the scan target to 0 and thus reducing scope for reclaim 
can result in increasing the scan priority more than is desirable, and since we 
base some vm heuristics based on that, that seemed concerning.

I'd rather start being a bit more cautious, erring on the side of scanning at 
least some pages from this memcg when priority gets elevated.

Thanks for the review!

