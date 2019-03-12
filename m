Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9414C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B094E214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:00:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B094E214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C5618E0003; Tue, 12 Mar 2019 04:00:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44D958E0002; Tue, 12 Mar 2019 04:00:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33F3F8E0003; Tue, 12 Mar 2019 04:00:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E19E68E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:00:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x23so2160140pfm.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 01:00:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:organization:references:date:message-id
         :mime-version;
        bh=NoCWmPWMbEDDUtlvUfSXY3QAjLpWmnzbXqbiPtoxywY=;
        b=d+uE3azHqL1ov5G2UJsjER6uXj8yXa5xWMiPohK9XbJwikFe2y4aqqN3xbc9NdlRrl
         ktiy7o8aY7hRdDQcMYt8CqQKcwE+4NTrvu+86if8IgwyLClokPR5Z28XwYRZjYiuCFJb
         t/Ob36PS/1Q/AQF+NfKqWt7j7pEki06h7fhy19F8nRYp/av8KU+1b375tLyn4KIGS1uM
         KSBfjaKhDaEKtfMAAL0Skb21iB7XClLd4KZWsU0ZmSACMLu5gPSOzWIDPSKcm1Gb4D8a
         ekSWKXuBJxx7yAmMw0aV+UdBokVpYV7wENi8POg9UR+XGghJKdiYocg5Qr7q1pLZT5w0
         TvZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jani.nikula@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVish3IJNQdY7rrQ9sVK7jXwl+U1dwsf1Ylc9jtWRczeOULKOJG
	6ODZ3nN2O/c5DdodZqGwnceM4mtExsy1/1rTpmrNxjCcVFtNrHmRQdFuM5CiPClhAX06jXLxyMI
	oUpGZjh8xqjYN5+XxH1UoBSXm7h1F9ZX9LcbLuGaM/WXpHAlDGgy31v8jin0U2xHVCA==
X-Received: by 2002:a17:902:8697:: with SMTP id g23mr39030147plo.30.1552377648569;
        Tue, 12 Mar 2019 01:00:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwi5gdVjXuDIMog4oQItA374edlk6x/VCm6jojBsT4QMWatTg/ZuCPP3Yimc1nQz27pAUcs
X-Received: by 2002:a17:902:8697:: with SMTP id g23mr39030042plo.30.1552377647540;
        Tue, 12 Mar 2019 01:00:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552377647; cv=none;
        d=google.com; s=arc-20160816;
        b=jdFpciCxqxUzj6bTSyfjSDaBjiI5a3jNJbV5dFwuqqHR1uNccKFd3kTPF4gXx7Pfr2
         IgVEX0IqF09u0b/0wAuPwnmHkCqdCXO0Ng7rpiDuWTtWthkWzh8jLQ/vBCnDLJ587Jfh
         HWgqCf9mg0TM+5dwEMrO03yW5X116BVvduw7D2aWyinZITc5cTB1YU680K4O0oSuLxPy
         4v1JOBc8JttPCJuZVoiQdm0DPlkJ0lU5Jx5MWbB5s+QmH4JiXzWNJm4L46RhwvUmbmNx
         nSFnihZx8YwSCyhuVOGgqb5VvJNm83319TTlqrehwEW5K2iDTixrODO2kDZFYod8wVZu
         9NOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:organization:in-reply-to
         :subject:cc:to:from;
        bh=NoCWmPWMbEDDUtlvUfSXY3QAjLpWmnzbXqbiPtoxywY=;
        b=azJVr6GPEOb7HTqd7vPPkDC+iBLkhQkS5/yn4UyyF3ynacCh3GfmnZCtTpWrA4RLE0
         XbZ0XfZ1p+6NWyCYl5xlk92O3cAMeXsGRT/g7v0xf8k3SRPJR0Dt0ABo2a70T4Qc5NRz
         4vh7MpYfTRTOW85u4SVkHOoHGzns2Y9cWQ1ibm9wWnUzhF5uTGm4WpccgOAshzQKcIUW
         FofugG2hyrQlSgv+e2dYZxLe3K55y6whGglV529qoEZJwew2pzqb1hS99pizCZ/0dHzh
         nc54B6jWTx5C0Z+axJzqvJMJmdwnrk/Z28V1N3QGcYFDWxMDGxavPBfQ48KfOkh7EYFv
         Rjcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jani.nikula@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b2si7436767pgl.531.2019.03.12.01.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 01:00:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jani.nikula@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jani.nikula@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Mar 2019 01:00:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,470,1544515200"; 
   d="scan'208";a="154206711"
Received: from hkrasnod-mobl.ger.corp.intel.com (HELO localhost) ([10.252.62.84])
  by fmsmga001.fm.intel.com with ESMTP; 12 Mar 2019 01:00:37 -0700
From: Jani Nikula <jani.nikula@linux.intel.com>
To: Al Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com>
Cc: airlied@linux.ie, akpm@linux-foundation.org, amir73il@gmail.com, chris@chris-wilson.co.uk, darrick.wong@oracle.com, david@fromorbit.com, dri-devel@lists.freedesktop.org, dvyukov@google.com, eparis@redhat.com, hannes@cmpxchg.org, hughd@google.com, intel-gfx@lists.freedesktop.org, jack@suse.cz, joonas.lahtinen@linux.intel.com, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com, mszeredi@redhat.com, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, rodrigo.vivi@intel.com, syzkaller-bugs@googlegroups.com, willy@infradead.org
Subject: Re: INFO: rcu detected stall in sys_sendfile64 (2)
In-Reply-To: <20190312040829.GQ2217@ZenIV.linux.org.uk>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
References: <00000000000010b2fc057fcdfaba@google.com> <0000000000008c75b50583ddb5f8@google.com> <20190312040829.GQ2217@ZenIV.linux.org.uk>
Date: Tue, 12 Mar 2019 10:00:36 +0200
Message-ID: <871s3cfrob.fsf@intel.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Mon, Mar 11, 2019 at 08:59:00PM -0700, syzbot wrote:
>> syzbot has bisected this bug to:
>> 
>> commit 34e07e42c55aeaa78e93b057a6664e2ecde3fadb
>> Author: Chris Wilson <chris@chris-wilson.co.uk>
>> Date:   Thu Feb 8 10:54:48 2018 +0000
>> 
>>     drm/i915: Add missing kerneldoc for 'ent' in i915_driver_init_early
>> 
>> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=13220283200000
>> start commit:   34e07e42 drm/i915: Add missing kerneldoc for 'ent' in i915..
>> git tree:       upstream
>> final crash:    https://syzkaller.appspot.com/x/report.txt?x=10a20283200000
>> console output: https://syzkaller.appspot.com/x/log.txt?x=17220283200000
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=abc3dc9b7a900258
>> dashboard link: https://syzkaller.appspot.com/bug?extid=1505c80c74256c6118a5
>> userspace arch: amd64
>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12c4dc28c00000
>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15df4108c00000
>> 
>> Reported-by: syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com
>> Fixes: 34e07e42 ("drm/i915: Add missing kerneldoc for 'ent' in
>> i915_driver_init_early")
>
> Umm...  Might be a good idea to add some plausibility filters - it is,
> in theory, possible that adding a line in a comment changes behaviour
> (without compiler bugs, even - playing with __LINE__ is all it would
> take), but the odds that it's _not_ a false positive are very low.

If it's not a false positive, it's bound to be good source material for
IOCCC.

BR,
Jani.


-- 
Jani Nikula, Intel Open Source Graphics Center

