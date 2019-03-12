Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C56DFC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:09:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DB08214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:09:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DB08214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A3EC8E0003; Tue, 12 Mar 2019 00:09:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 150EA8E0002; Tue, 12 Mar 2019 00:09:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 041738E0003; Tue, 12 Mar 2019 00:09:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A597F8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:08:59 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l1so515421wrn.13
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:08:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=uXh7454/9Uf8isKtFfGwageUQb08ErDcitp4OA86oVI=;
        b=PsHsRy1YbO5lIPkQqUEyx99rVvz6I1iR0NNVK4+lZlCdf+r1FhlZQZA6+GcA+r/kFG
         GD+vZm8KOrRe7/pQTUOo56gZ2o6NRfIAZmALRrlLQrnZ9EK5Qdy9A4xaHj+yR7nrgFDE
         05xz2tdJCZd23Q9x2vKv10QkyhmPmAqqjcrWOtheSrG8j8AGKY7THAmYCnE/0j8CGcgW
         jzQ38LvhSLOUxTjGZqqiipDe9BG9+YMJnsvskkVaCY1NZ8M3DHYngyID11en/FNfKrNs
         gT6zkCUsvOySRaCZzmG3ZUYZARQr3Lu1QAf3uY7l6s2y/bJ1bN9FOHIyp4XjYQvswbSO
         f6aQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAURQmJntFYOqqwivnK+qcFRMdiayePDENQBxP0MFOEutcrd8yaX
	KsZfIohl39EEBsOIZilsRzUj8SJqb2TM7wgVgeOU6PJRlbq6e2ReRoBlq0K8cMdRSitFzjnVTM4
	U/v2Cx9YTFKYiJmNMLPFbtdWKTo5fWC5Y71EXnyU9eyCdX0Mq+ZAGcWNbAP8atuTerg==
X-Received: by 2002:a1c:d18a:: with SMTP id i132mr806226wmg.27.1552363739236;
        Mon, 11 Mar 2019 21:08:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyra6jahAlTYfPCDVhuUy+q9MbNEfirrac53M0Uu/iePGkKNFfPOOEnZKr09jv4OyZKqHGl
X-Received: by 2002:a1c:d18a:: with SMTP id i132mr806202wmg.27.1552363738401;
        Mon, 11 Mar 2019 21:08:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552363738; cv=none;
        d=google.com; s=arc-20160816;
        b=KyRsY+BSTDpHGRYSlgjrF98wDBGlXov0EPHfmYWWb5QJD1sT9JBn6sYc4hGz89JOdB
         QESZ9u+DA8uutVjyorHIb6Gf0kE4m9YCVmKkQqgLClOaZGRRmnDq4jIFt9MfIn4+dmhl
         4UdiY/FyWcYHNTzs0lh4ElfJOhazXVOuazevi7OHJpSfl7rsDGCb5dJB1b9zJ715HS4n
         me3bzr15+lpU/0rTx9I8v8Ua8Z/4UDrigGePw00o3mdlh+gXqBUAvpx0cmXrTxqTBAZF
         cSdT6NwaL9WXR0CzuhqON3S9RIUNH8cT3fwqDZe9A/t55FH82sGnLXb1pYMbk/R4ZerZ
         g7dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=uXh7454/9Uf8isKtFfGwageUQb08ErDcitp4OA86oVI=;
        b=yyFXprhuAkqzNU8stw4ktWVps8wfZPQbp284X3pb0iyoKp8yMbfpMfUbr/lAPOqT05
         qU02VviSZildx8gaEoIvaSf2zawTmqNN4HsmxvqP/PBYJt1fcLG8bBwYBZ8lHz+ntAtW
         mlqDe59OaaUEj5uhL+6cgJPbb04jgXkYV+7tOSPv4FnVFd/WVq0X/WmpRwzjBWm1FVuS
         F4c2yC2ar/UZ8lJ1/hH7jq8s77hHPxDJIzW2hwleMQhjanqbJpvfqj9y2guZEI2DvZgv
         1wdul3byFcpSXjnkSjNliRu16AEcL8NWvd/21xP2eIRqKgRWwh7MtybtYugkz4dGFvuC
         aveg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id i7si4649849wrp.46.2019.03.11.21.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 21:08:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1h3YiL-0003ts-SD; Tue, 12 Mar 2019 04:08:30 +0000
Date: Tue, 12 Mar 2019 04:08:29 +0000
From: Al Viro <viro@zeniv.linux.org.uk>
To: syzbot <syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com>
Cc: airlied@linux.ie, akpm@linux-foundation.org, amir73il@gmail.com,
	chris@chris-wilson.co.uk, darrick.wong@oracle.com,
	david@fromorbit.com, dri-devel@lists.freedesktop.org,
	dvyukov@google.com, eparis@redhat.com, hannes@cmpxchg.org,
	hughd@google.com, intel-gfx@lists.freedesktop.org, jack@suse.cz,
	jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com,
	jrdr.linux@gmail.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mingo@redhat.com, mszeredi@redhat.com,
	penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org,
	rodrigo.vivi@intel.com, syzkaller-bugs@googlegroups.com,
	willy@infradead.org
Subject: Re: INFO: rcu detected stall in sys_sendfile64 (2)
Message-ID: <20190312040829.GQ2217@ZenIV.linux.org.uk>
References: <00000000000010b2fc057fcdfaba@google.com>
 <0000000000008c75b50583ddb5f8@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000008c75b50583ddb5f8@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 08:59:00PM -0700, syzbot wrote:
> syzbot has bisected this bug to:
> 
> commit 34e07e42c55aeaa78e93b057a6664e2ecde3fadb
> Author: Chris Wilson <chris@chris-wilson.co.uk>
> Date:   Thu Feb 8 10:54:48 2018 +0000
> 
>     drm/i915: Add missing kerneldoc for 'ent' in i915_driver_init_early
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=13220283200000
> start commit:   34e07e42 drm/i915: Add missing kerneldoc for 'ent' in i915..
> git tree:       upstream
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=10a20283200000
> console output: https://syzkaller.appspot.com/x/log.txt?x=17220283200000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=abc3dc9b7a900258
> dashboard link: https://syzkaller.appspot.com/bug?extid=1505c80c74256c6118a5
> userspace arch: amd64
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12c4dc28c00000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15df4108c00000
> 
> Reported-by: syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com
> Fixes: 34e07e42 ("drm/i915: Add missing kerneldoc for 'ent' in
> i915_driver_init_early")

Umm...  Might be a good idea to add some plausibility filters - it is,
in theory, possible that adding a line in a comment changes behaviour
(without compiler bugs, even - playing with __LINE__ is all it would
take), but the odds that it's _not_ a false positive are very low.

