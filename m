Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0021C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:33:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 877F823878
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:33:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="N6W+xOAX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 877F823878
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E33966B0005; Tue,  3 Sep 2019 11:33:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE3F06B0006; Tue,  3 Sep 2019 11:33:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF8A16B0007; Tue,  3 Sep 2019 11:33:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0033.hostedemail.com [216.40.44.33])
	by kanga.kvack.org (Postfix) with ESMTP id A9DF66B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 11:33:01 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5123F181AC9B6
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:33:01 +0000 (UTC)
X-FDA: 75894002562.20.tail06_71a0de6be2512
X-HE-Tag: tail06_71a0de6be2512
X-Filterd-Recvd-Size: 5765
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:33:00 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id r15so14770851qtn.12
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 08:33:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=7z24kFn1qyfn97kG5Kld1bO8ER8wbRTx80HXtH0YfLI=;
        b=N6W+xOAXiUXU0wvHWttTDLMyO2AzXhN45qBg4wtqJdxne7OSSiXK0g1BTXPnat77Va
         BmH2KZF5dbj5r7R4vN474M2hJlNat9522gVBia2FW7Wg1NwFPetlfOH68zDenNfVLXZh
         45O/rb20ZXcd/PnYJwl3rq7pu7yNeEIAUO97DnlXmohSGQkdCZM5XUBZNPMUPIxlTAZU
         zV9+HvCw8IB7dr+DiwVO6VL6XRPVTblAGIZl7xjVKk6EDpqX148S56FXLJnRKE4LyiJd
         /wC/Y1KZxzeB0Y6G21lndTOWQNMLytlBO9FZGA/wg4rJiwlYHHHSzsZDelSiTALE2nGH
         ZaDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=7z24kFn1qyfn97kG5Kld1bO8ER8wbRTx80HXtH0YfLI=;
        b=O/dqi0qgdA+eZRXGOz8h9djaz+aFeCZaLeat7UzGEwwC0yfARWPBIH7CijvQVbrb04
         fUGDxAXUQ6wShg3lpyCnH3BbtkG35yHKJLiYQWMVaKHIl2NMcpuma9BJOhBM97uVJN5R
         3Lk4OMvpaDNNJwX2VctQMGokGfjykRv6JuTu+0+C/JJmlAg48i+KiLoTaatpgmQDEgFs
         KvXTgqAOrIDUluBTuOt46pKk/gyJFM6KKvdxC+PZLn+Ztnif4ZQBl3dAw1fdPTvRUdk3
         ljzLXXQ25u7v09tvPIrpfX08K1wQxm6o2ZPv7yv60VN9ifxLQ9Nj9w5Etcme0Q9gK1m6
         3IoQ==
X-Gm-Message-State: APjAAAU2R86mADg0oRX0cSi0ix0Ze+QMRPkOiEbVaio2YplnpaQ29KrP
	TWTfKR6QAAYRFJbIhY/LS4nTJg==
X-Google-Smtp-Source: APXvYqy+rkfm6UNLWPWcA+BzO7i7KYOSxg0WuoH/76pZjIUl2i5Lo4V9xmK1obnjDBesOHq7hFGDjg==
X-Received: by 2002:a05:6214:1709:: with SMTP id db9mr5586290qvb.243.1567524780147;
        Tue, 03 Sep 2019 08:33:00 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 131sm8780749qkg.1.2019.09.03.08.32.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Sep 2019 08:32:59 -0700 (PDT)
Message-ID: <1567524778.5576.59.camel@lca.pw>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo
 Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes
 <rientjes@google.com>,  LKML <linux-kernel@vger.kernel.org>
Date: Tue, 03 Sep 2019 11:32:58 -0400
In-Reply-To: <20190903151307.GZ14028@dhcp22.suse.cz>
References: <20190903144512.9374-1-mhocko@kernel.org>
	 <1567522966.5576.51.camel@lca.pw> <20190903151307.GZ14028@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-03 at 17:13 +0200, Michal Hocko wrote:
> On Tue 03-09-19 11:02:46, Qian Cai wrote:
> > On Tue, 2019-09-03 at 16:45 +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > dump_tasks has been introduced by quite some time ago fef1bdd68c81
> > > ("oom: add sysctl to enable task memory dump"). It's primary purpose is
> > > to help analyse oom victim selection decision. This has been certainly
> > > useful at times when the heuristic to chose a victim was much more
> > > volatile. Since a63d83f427fb ("oom: badness heuristic rewrite")
> > > situation became much more stable (mostly because the only selection
> > > criterion is the memory usage) and reports about a wrong process to
> > > be shot down have become effectively non-existent.
> > 
> > Well, I still see OOM sometimes kills wrong processes like ssh, systemd
> > processes while LTP OOM tests with staight-forward allocation patterns.
> 
> Please report those. Most cases I have seen so far just turned out to
> work as expected and memory hogs just used oom_score_adj or similar.
> 
> > I just
> > have not had a chance to debug them fully. The situation could be worse with
> > more complex allocations like random stress or fuzzy testing.
> 
> Nothing really prevents enabling the sysctl when doing OOM oriented
> testing.
> 
> > > dump_tasks can generate a lot of output to the kernel log. It is not
> > > uncommon that even relative small system has hundreds of tasks running.
> > > Generating a lot of output to the kernel log both makes the oom report
> > > less convenient to process and also induces a higher load on the printk
> > > subsystem which can lead to other problems (e.g. longer stalls to flush
> > > all the data to consoles).
> > 
> > It is only generate output for the victim process where I tested on those
> > large
> > NUMA machines and the output is fairly manageable.
> 
> The main question here is whether that information is useful by
> _default_ because it is certainly not free. It takes both time to crawl
> all processes and cpu cycles to get that information to the console
> because printk is not free either. So if it more of "nice to have" than
> necessary for oom analysis then it should be disabled by default IMHO.

It also feels like more a band-aid micro-optimization with the side-effect that
affecting debuggability, as there could be loads of console output anyway during
a kernel OOM event including failed allocation warnings. I suppose if you want
to change the default behavior, the bar is high with more data and
justification.

