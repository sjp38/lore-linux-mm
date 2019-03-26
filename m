Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F742C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:12:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B43E620830
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:12:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="k6XFJyGw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B43E620830
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BC756B0007; Tue, 26 Mar 2019 04:12:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46AA86B0008; Tue, 26 Mar 2019 04:12:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 358D46B000A; Tue, 26 Mar 2019 04:12:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1607F6B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:12:44 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id v193so4923150itv.9
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:12:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YdFwkF4eUySjbpG+38wjJdvK3fCy24c6M03FoBUoupk=;
        b=kTFz0X9AoDYQ2aKdZA08Icx/CRzZXTGOUO+arucD8VTMv3di23CA9DTrE5tr9lQT4X
         H17uKzzIo2wcLTX37uDkcQS4fREVxtHOyJVb5422o9G09v+oRyYqgCfMYrqNz+MOqRku
         fDRBuZuhah7I8+439yAyY0E4YXa5TgAAaVe+NzRjnk4SjPX+e/f3g4cXgqkRFQ/3NImO
         C6/3y+CFs/YaJ4JvPtfiReLJ87xoia8rubx/lz6y8wTQvxMKqPUFzHL9QsMqt7I0q8Hn
         IDpEwtvR4SMEEaFU2d3bG5PHogIJyM56oYIznl9OPQs/6LRSCletuaKrCIoajdnspmJM
         8bFA==
X-Gm-Message-State: APjAAAV6F6D1i+PpRzEjiqfcBvJbQPlvBrLm7p0r67XgyqdW+cGmnwUs
	65ZcUpaLBFbU8CUNBKA+aXRaG5Vme+wgzVFzoCQC9LK3LsVn+RPkd2b7UsmFjtrgACGTnFjcd4s
	muRDXe2FembtSdtaY2sWQ/RlI55FXgCq6Y06UKVz7dTezxAWqyIxDcxeq1ZC77mttBw==
X-Received: by 2002:a24:7b42:: with SMTP id q63mr4220878itc.174.1553587963726;
        Tue, 26 Mar 2019 01:12:43 -0700 (PDT)
X-Received: by 2002:a24:7b42:: with SMTP id q63mr4220848itc.174.1553587962924;
        Tue, 26 Mar 2019 01:12:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553587962; cv=none;
        d=google.com; s=arc-20160816;
        b=sSJFOcP35xdytzf7keNKWLT2VRU2D5fJDb6bncJURSh2FYVrJDy2Ryo6xNS87HDd8q
         DxTvzi6tftcBfsIsK/RuLLg1D3LQx7DRZRRFdMk1nXN6wFU0Mu4Ouymf7G1DbJaVlh6t
         mDxTgU+LmBgKpS4zR9oNLcwdFL6LKYwS2Bv1u6A2rZbLMCZtNx+j4RFTPn3o/3W6PnVd
         Ejpx1ikKxoz27JopKoWW1x/ik6gkq51C7/+xzqj1foOGnRiWdit7JpeXzNpcbSLlzGJz
         1aA+rZ36E+NjKSMGDdpLKzSBMtae8Px90m6YIz76d35HL6Q7F5a/7h4JabXlxSkqwMeu
         3xcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YdFwkF4eUySjbpG+38wjJdvK3fCy24c6M03FoBUoupk=;
        b=ObeQIM8lSI5U9O5BXyVAvB8SPN/RPgfX0RwdSaIx+/RzTtQefqIADoUYsek5Sv4Ipu
         X0GrLvVurF7AQ5pE+RKnR5IRQDxg6z1C7LckP6HHu9r7ItQslPvXr61/E3DEnZ+Q/OfP
         /qNNyNa0RNUdTHoxkpvvoGKxLLpa+iBFRlML5u7WPzIPNc98dMLY91nAdMl9Z6Lt+6xT
         XkzPncLgSTZUss7FmfOIH1ey9yH1IcDxtlzMDXAY8A9Elq35lDfIkqL6lOkjbQSx7KPN
         1Bzuh+VOuT+n/Sqyg7KzXr2CDNNEc7xftYAeUWiXzLCxfijdVJfzL3ROUdv+G6nk7NUr
         eLDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=k6XFJyGw;
       spf=pass (google.com: domain of liumartin@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liumartin@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor12078209ioj.90.2019.03.26.01.12.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 01:12:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of liumartin@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=k6XFJyGw;
       spf=pass (google.com: domain of liumartin@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liumartin@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YdFwkF4eUySjbpG+38wjJdvK3fCy24c6M03FoBUoupk=;
        b=k6XFJyGwJ9uMM5uZPWX/AMT7fviQV0Ld1mcPlddQHs0cPIvKIZsAGtkGGxowospoCT
         dtY6QW0pQBRdQZw/Pzw1xGUnrxiMWMMWQoLuH0L+NTAhjv0l+Yb/scBRb8Eepi2+jpsZ
         +ZfSqGLB3qiRjeQWh0Tgul4DOKaGm71Q8paP7zVq4PLWFJDKx4e7zw5OVJkORY5a2mpV
         ReGqnFwm0nuny+7m0ehupOQZYBEJ5uTlS1sAE9PGHyJC7FgYKKgwDVuTukwLz/+hRlTd
         MGNnI3tJskCS+Wu1/Aa6+rE98oi17qFjkFteyqgBOHmpSXEWFl1O8/BEaF0M9h/LvEhh
         k/iQ==
X-Google-Smtp-Source: APXvYqzUewoC4h/6psWy97TNreJAfbfzJbNTFpBTiFptGULlXyAtjw1mAFFx3ekIO/Ni0Jr6DpSEmg==
X-Received: by 2002:a5e:db48:: with SMTP id r8mr20194656iop.220.1553587962220;
        Tue, 26 Mar 2019 01:12:42 -0700 (PDT)
Received: from google.com ([2401:fa00:fc:202:858d:45ea:f905:5ed4])
        by smtp.gmail.com with ESMTPSA id t62sm6882457ita.35.2019.03.26.01.12.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 01:12:41 -0700 (PDT)
Date: Tue, 26 Mar 2019 16:12:33 +0800
From: Martin Liu <liumartin@google.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Mark Salyzyn <salyzyn@android.com>, akpm@linux-foundation.org,
	axboe@kernel.dk, dchinner@redhat.com, jenhaochen@google.com,
	salyzyn@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC PATCH] mm: readahead: add readahead_shift into backing
 device
Message-ID: <20190326081233.GA175058@google.com>
References: <20190322154610.164564-1-liumartin@google.com>
 <20190325121628.zxlogz52go6k36on@wfg-t540p.sh.intel.com>
 <9b194e61-f2d0-82cb-30ac-95afb493b894@android.com>
 <20190326013058.ykdwxbfkk3x3pvtu@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326013058.ykdwxbfkk3x3pvtu@wfg-t540p.sh.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 09:30:58AM +0800, Fengguang Wu wrote:
> On Mon, Mar 25, 2019 at 09:59:31AM -0700, Mark Salyzyn wrote:
> > On 03/25/2019 05:16 AM, Fengguang Wu wrote:
> > > Martin,
> > > 
> > > On Fri, Mar 22, 2019 at 11:46:11PM +0800, Martin Liu wrote:
> > > > As the discussion https://lore.kernel.org/patchwork/patch/334982/
> > > > We know an open file's ra_pages might run out of sync from
> > > > bdi.ra_pages since sequential, random or error read. Current design
> > > > is we have to ask users to reopen the file or use fdavise system
> > > > call to get it sync. However, we might have some cases to change
> > > > system wide file ra_pages to enhance system performance such as
> > > > enhance the boot time by increasing the ra_pages or decrease it to
> > > 
> > > Do you have examples that some distro making use of larger ra_pages
> > > for boot time optimization?
> > 
> > Android (if you are willing to squint and look at android-common AOSP
> > kernels as a Distro).
> 
> OK. I wonder how exactly Android makes use of it. Since phones are not
> using hard disks, so should benefit less from large ra_pages.  Would
> you kindly point me to the code?
>
Yes, one of the example is as below.
https://source.android.com/devices/tech/perf/boot-times#optimizing-i-o-
efficiency
> > > Suppose N read streams with equal read speed. The thrash-free memory
> > > requirement would be (N * 2 * ra_pages).
> > > 
> > > If N=1000 and ra_pages=1MB, it'd require 2GB memory. Which looks
> > > affordable in mainstream servers.
> > That is 50% of the memory on a high end Android device ...
> 
> Yeah but I'm obviously not talking Android device here. Will a phone
> serve 1000 concurrent read streams?
> 
For Android, some important, persistent services and native HALs might
hold fd for a long time unless request a restart action and then would
impact overall user experience(guess more than 100). For some low end
devices which is a big portion of Android devices, their memory size
might be even smaller. Thus, when the device is under memory pressure,
this might bring more overhead to impact the performance. As current
design, we don't have a way to shrink readahead immediately. This
interface gives the flexibility to an adiminstrator to decide how
readahed to participate the mitigation level base on the metric it has.

> > > Sorry but it sounds like introducing an unnecessarily twisted new
> > > interface. I'm afraid it fixes the pain for 0.001% users while
> > > bringing more puzzle to the majority others.
> > >2B Android devices on the planet is 0.001%?
> 
> Nope. Sorry I didn't know about the Android usage.
> Actually nobody mentioned it in the past discussions.
> 
> > I am not defending the proposed interface though, if there is something
> > better that can be used, then looking into:
> > > 
> > > Then let fadvise() and shrink_readahead_size_eio() adjust that
> > > per-file ra_pages_shift.
> > Sounds like this would require a lot from init to globally audit and
> > reduce the read-ahead for all open files?
> 
> It depends. In theory it should be possible to create a standalone
> kernel module to dump the page cache and get the current snapshot of
> all cached file pages. It'd be a one-shot action and don't require
> continuous auditing.
> 
> [RFC] kernel facilities for cache prefetching
> https://lwn.net/Articles/182128
> 
> This tool may also work. It's quick to get the list of opened files by
> walking /proc/*/fd/, however not as easy to get the list of cached
> file names.
> 
> https://github.com/tobert/pcstat
> 
> Perhaps we can do a simplified /proc/filecache that only dumps the
> list of cached file names. Then let mincore() based tools take care
> of the rest work.
> 
Thanks for the information, they are very useful. For Android, it would
keep updating pretty frequently and the lists might need to be updated
as the end users install apps, runtime optimization or get new OTA.
Therefore, this might request pretty much effort to maintain this.
Please kindly correct me if any misunderstanding. Thanks.

Regards,
Martin

