Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CB06C4649B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 12:45:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2993218A3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 12:45:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Y78t9ohm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2993218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66F696B0006; Fri,  5 Jul 2019 08:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 620AA8E0003; Fri,  5 Jul 2019 08:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C0F58E0001; Fri,  5 Jul 2019 08:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 162436B0006
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 08:45:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x19so5532975pgx.1
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 05:45:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dF5ldfW86FJCU5Kc3o1c+7BuYCZNz4gnsUxsM2MILhg=;
        b=tywrF0mFn9Av5OFvH92apD253D9QceHKyJknYGe2kWVMulAXuz/hbrDvLhbWmisxoY
         my0RKgkbouPc9FKZ9Ah9K9kh6P8zrIj+SLBeAp//VxqRDIKiK0HJi6xeTjhnXMSKjURB
         nG8p1Z3F8gvqxIeE+UnTEG7IGdzAxL0bRDHSvBb/N2dGtZ42RKarN7kCBW8Mq7t7bREv
         onh/CXe6VcOTJkRcgZvekw04+4J4dlwxfZu1ru9He+A5jdaMTaZDcuCh3eTz1S5lwoJE
         Y0ggWig4/sVv12NibG92Lt96eioIKRUQqLKV+kVNB+W6P5rZb2EtARyQPssVWdVQ691L
         pUmg==
X-Gm-Message-State: APjAAAVk8QV+OfLZUr3DL29KPM4ks0U4YE4vTXp3mU71qFXLPKCv9DgQ
	WzvnEY54iBrWOscV9i0L9gIHLdJFROBQapig9fdu3FGCG+W7s/IBUQf0ffQ/azN/V4UDDgPMzBE
	6Onqq1zuOddHKSleGxMiJAy+Yfi926nHCEI1g/IXWK1u1NpSat8iNpFYpwyGRKOj3BQ==
X-Received: by 2002:a17:90a:3210:: with SMTP id k16mr5262946pjb.13.1562330710662;
        Fri, 05 Jul 2019 05:45:10 -0700 (PDT)
X-Received: by 2002:a17:90a:3210:: with SMTP id k16mr5262872pjb.13.1562330709912;
        Fri, 05 Jul 2019 05:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562330709; cv=none;
        d=google.com; s=arc-20160816;
        b=JszisLoGkCDHnZFvWLLmd3Vpf8pW4i8moq9SR5K0+Eh6kPSFw/rZ9o7LEwzRYqsc/M
         gi1HqQHx0xmFFS1LCXmiO71V0Nmkddgteq141ZGUTtb0mRR3YXJDOIA26uJ4dFlm6TVc
         wuCCYPooSOyJXlEra8wr+3WKob5RoUhpX5g0zAPAhHNljnzqIoQj0lbzVg4+5hWIztRW
         YhuxLEddZbNXv+sgB8fMzWtrvtMD3lDC+oWD2bkmbZ/ySSoC22NnBowHHddun+Sl5Ke0
         OQQ2bRAvkad/7IsJoy3D7KHcIZszsBm8lJnU2EcK0oWxCIW6EgeUXrC83P9yI3G6vUK8
         w9lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dF5ldfW86FJCU5Kc3o1c+7BuYCZNz4gnsUxsM2MILhg=;
        b=vgpLrHcKGXl8MpBIL8Y/nCDXGDpXeYlx1eeGd4pd90CgI7vy+314loUp0FqVZxAB14
         yJASpkCybKxfI82V8VF7F5FnLE8RVLMGt3lD4N8f2Iibj9dpgaRjdCBytvVyoWAHYKY4
         N11KrKbS1pg/fEkBwX2b+uxqMMFn94cB0W5diBboibkddxV/u1aA+NG7HOAe3Gws34DZ
         pzGI719lVW1NXTk148tJ2x/Wfe1Xm3kMV6MH+vpzAT45youegezF/ARa884pja7RoHxZ
         P0yxdstF7HP1KQc9cX14trczLsQi6l6O2WxGB9UO3BvV3AuNi2BrnNBPYGr3RzN+OcYs
         wb1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Y78t9ohm;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor10410011pln.14.2019.07.05.05.45.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 05:45:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Y78t9ohm;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dF5ldfW86FJCU5Kc3o1c+7BuYCZNz4gnsUxsM2MILhg=;
        b=Y78t9ohm9IjqJTYbAV0G0UpCaRpc5X9RScVdIdmz4eqVB1CtoQpRVENQv5H9OJB6u3
         IHW38yAnNbwzW6vcGSiPkXs9kW4CnIKtbKQQihf+CPDRaHhL04ZyRYbRyfKQffGvavIp
         D8IdAu4ImWWGg3ot7QhkuD+LT+WNmRKXlpEXE=
X-Google-Smtp-Source: APXvYqxMUTixTbN+cdcvlkTjbvWDrPyHAWnhOqeIT0sxQ7x+/ZOrGTKueCUPUnH3QwRNCyffO+Wgnw==
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr5266993plb.139.1562330709214;
        Fri, 05 Jul 2019 05:45:09 -0700 (PDT)
Received: from google.com ([2401:fa00:1:b:d89e:cfa6:3c8:e61b])
        by smtp.gmail.com with ESMTPSA id y22sm8626527pgj.38.2019.07.05.05.45.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 05 Jul 2019 05:45:08 -0700 (PDT)
Date: Fri, 5 Jul 2019 20:45:05 +0800
From: Kuo-Hsin Yang <vovoy@chromium.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Minchan Kim <minchan@kernel.org>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: scan anonymous pages on file refaults
Message-ID: <20190705124505.GA173726@google.com>
References: <20190628111627.GA107040@google.com>
 <20190701081038.GA83398@google.com>
 <20190703143057.GQ978@dhcp22.suse.cz>
 <20190704094716.GA245276@google.com>
 <20190704110425.GD5620@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190704110425.GD5620@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 04, 2019 at 01:04:25PM +0200, Michal Hocko wrote:
> On Thu 04-07-19 17:47:16, Kuo-Hsin Yang wrote:
> > On Wed, Jul 03, 2019 at 04:30:57PM +0200, Michal Hocko wrote:
> > > 
> > > How does the reclaim behave with workloads with file backed data set
> > > not fitting into the memory? Aren't we going to to swap a lot -
> > > something that the heuristic is protecting from?
> > > 
> > 
> > In common case, most of the pages in a large file backed data set are
> > non-executable. When there are a lot of non-executable file pages,
> > usually more file pages are scanned because of the recent_scanned /
> > recent_rotated ratio.
> > 
> > I modified the test program to set the accessed sizes of the executable
> > and non-executable file pages respectively. The test program runs on 2GB
> > RAM VM with kernel 5.2.0-rc7 and this patch, allocates 2000 MB anonymous
> > memory, then accesses 100 MB executable file pages and 2100 MB
> > non-executable file pages for 10 times. The test also prints the file
> > and anonymous page sizes in kB from /proc/meminfo. There are not too
> > many swaps in this test case. I got similar test result without this
> > patch.
> 
> Could you record swap out stats please? Also what happens if you have
> multiple readers?

Checked the swap out stats during the test [1], 19006 pages swapped out
with this patch, 3418 pages swapped out without this patch. There are
more swap out, but I think it's within reasonable range when file backed
data set doesn't fit into the memory.

$ ./thrash 2000 100 2100 5 1 # ANON_MB FILE_EXEC FILE_NOEXEC ROUNDS PROCESSES
Allocate 2000 MB anonymous pages
active_anon: 1613644, inactive_anon: 348656, active_file: 892, inactive_file: 1384 (kB)
pswpout: 7972443, pgpgin: 478615246
Access 100 MB executable file pages
Access 2100 MB regular file pages
File access time, round 0: 12.165, (sec)
active_anon: 1433788, inactive_anon: 478116, active_file: 17896, inactive_file: 24328 (kB)
File access time, round 1: 11.493, (sec)
active_anon: 1430576, inactive_anon: 477144, active_file: 25440, inactive_file: 26172 (kB)
File access time, round 2: 11.455, (sec)
active_anon: 1427436, inactive_anon: 476060, active_file: 21112, inactive_file: 28808 (kB)
File access time, round 3: 11.454, (sec)
active_anon: 1420444, inactive_anon: 473632, active_file: 23216, inactive_file: 35036 (kB)
File access time, round 4: 11.479, (sec)
active_anon: 1413964, inactive_anon: 471460, active_file: 31728, inactive_file: 32224 (kB)
pswpout: 7991449 (+ 19006), pgpgin: 489924366 (+ 11309120)

With 4 processes accessing non-overlapping parts of a large file, 30316
pages swapped out with this patch, 5152 pages swapped out without this
patch. The swapout number is small comparing to pgpgin.

[1]: https://github.com/vovo/testing/blob/master/mem_thrash.c

