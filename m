Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3079C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 13:20:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E2172146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 13:20:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E2172146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C05848E0003; Tue, 19 Feb 2019 08:20:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB34F8E0002; Tue, 19 Feb 2019 08:20:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA1DC8E0003; Tue, 19 Feb 2019 08:20:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1B08E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 08:20:29 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u12so325657edo.5
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:20:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZYZTnLbrqeA+bu8RZJkEStbaDCiakaQZ8WxxYegUySQ=;
        b=Z7Xce5kUbdolSqjs03uAzD/xeE9FgvIM0zhe1371v2rdqmllf+Y9GmPhMkq4lWB8E+
         gHpAuUp5QdWPMph56A52mBaLYnanAOnMfKSzi5PFjZlOhJhVNmLVcQzBb6WTyYSlQzOu
         cV7hFO38Vp2TLfUECYATM9VML8DpOYdHffs84eIWLFcNzhPzUGrBEL6fX3lS7hDSpwbS
         U/KI+Pd8kv+KgIho0kgB6MZQobxZANNS4ipTdQvztVBKCyLKv+oR6LNt18c88lWd+UiC
         oRVwDHmlef95vJaamM8XiqwBVfEDLkLuR/9gocqurq0GWZCdvaRFV1Y4QzsYcwOUrn/N
         fIXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAubCrgvdsCgghcWhZ3ybm8ceh3j02uu3OG+nY0iapIK2IFsKPEaY
	yYJanMgtfJb6+Fmo5JV5iqY8xVl8u7oy1sXBJ5qUr9ZeJ1NvcGICD5tqjqFhDxQesincT/uMO+K
	vtHObnWFmbTEc1GcWmHYRxahyzFJ6F1/4L13vD9evGd9Nrv154c2B3YzdCbteyKveiw==
X-Received: by 2002:a50:b2e1:: with SMTP id p88mr22736684edd.254.1550582428658;
        Tue, 19 Feb 2019 05:20:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbOtgq9lg6KZzJbkTgNyNC3VZGA8PW3oElyN8n0DY2TGCx7iKb4LUynoWJo61/eJ4ipXAia
X-Received: by 2002:a50:b2e1:: with SMTP id p88mr22736620edd.254.1550582427608;
        Tue, 19 Feb 2019 05:20:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550582427; cv=none;
        d=google.com; s=arc-20160816;
        b=pV99t1KzYgJ86E+KeMD5a0vILnQoyHO/11J+ZHNIcAeYy4UTUuXDgWxYUiBw7M/HzI
         RK4DekfZL2QrcFuQryd5hj+ojaJY9nPWHqC3ok4j6GM0klzdlnTr19Q5J2CdBQXgRo4I
         dyQ54QaN1uOBm+haKBuX/ywykHbE0PPQOpfRyPLXQyZWrF65hAkaOK4CX1e1aDUMo+Mg
         aGOYyFNxKq6dJigrlCOcP1uCj8FuBElONikkR2BxwPoWvQtypRUOTi7/Tu/f9H82iEKl
         phDrbMo336sDE8Rw8vLag9cp9J1Z/XLdDMVZoeh1kEU1A2bpAYpG82udRh6uK1zi46R1
         mlHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZYZTnLbrqeA+bu8RZJkEStbaDCiakaQZ8WxxYegUySQ=;
        b=d8KiT9DLQo+lE02OBxEN10cFQzY5I8nZjy/6AK9ws4PNwvAyS8DOIw9ePhu1MWgWFz
         u0tDTNWd6fChW8EVo50Qvl/zUG+p0Ni3WDzUfWLx50P4zH2Nd2Gxgzi+M0aY4L1It50e
         RgcE2AETD8agkRJXZn+g5Tc9tLALyDaw+1Nf1A0sNI19/DrAaOOeyZFrTXyrI956iKnI
         hd+bwAQ8LmssOFu4rQijK/iVa/XqGsfAtBaMPJ4GxKkbdoC1SmC4DD4R9tWoxNy9qAAq
         RnZeQFDf3OfwE/3na2eSursUA1MjLvyGIdR6EwQgFgHBuIJYZ54NlB8y5Zu6pkrUf6zf
         k6cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c4si1449583edb.409.2019.02.19.05.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 05:20:27 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0C408AC8A;
	Tue, 19 Feb 2019 13:20:27 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 3583A1E1570; Tue, 19 Feb 2019 14:20:26 +0100 (CET)
Date: Tue, 19 Feb 2019 14:20:26 +0100
From: Jan Kara <jack@suse.cz>
To: Meelis Roos <mroos@linux.ee>
Cc: Jan Kara <jack@suse.cz>, "Theodore Y. Ts'o" <tytso@mit.edu>,
	linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-block@vger.kernel.org, linux-mm@kvack.org
Subject: Re: ext4 corruption on alpha with 4.20.0-09062-gd8372ba8ce28
Message-ID: <20190219132026.GA28293@quack2.suse.cz>
References: <fb63a4d0-d124-21c8-7395-90b34b57c85a@linux.ee>
 <1c26eab4-3277-9066-5dce-6734ca9abb96@linux.ee>
 <076b8b72-fab0-ea98-f32f-f48949585f9d@linux.ee>
 <20190216174536.GC23000@mit.edu>
 <e175b885-082a-97c1-a0be-999040a06443@linux.ee>
 <20190218120209.GC20919@quack2.suse.cz>
 <4e015688-8633-d1a0-308b-ba2a78600544@linux.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e015688-8633-d1a0-308b-ba2a78600544@linux.ee>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 19-02-19 14:17:09, Meelis Roos wrote:
> > > > > The result of the bisection is
> > > > > [88dbcbb3a4847f5e6dfeae952d3105497700c128] blkdev: avoid migration stalls for blkdev pages
> > > > > 
> > > > > Is that result relevant for the problem or should I continue bisecting between 4.20.0 and the so far first bad commit?
> > > > 
> > > > Can you try reverting the commit and see if it makes the problem go away?
> > > 
> > > Tried reverting it on top of 5.0.0-rc6-00153-g5ded5871030e and it seems
> > > to make the kernel work - emerge --sync succeeded.
> There is more to it.
> 
> After running 5.0.0-rc6-00153-g5ded5871030e-dirty (with the revert of
> that patch) successfully for Gentoo update, I upgraded the kernel to
> 5.0.0-rc7-00011-gb5372fe5dc84-dirty (todays git + revert of this patch)
> and it broke on rsync again:
> 
> RepoStorageException: command exited with status -6: rsync -a --link-dest /usr/portage --exclude=/distfiles --exclude=/local --exclude=/lost+found --exclude=/packages --exclude /.tmp-unverified-download-quarantine /usr/portage/ /usr/portage/.tmp-unverified-download-quarantine/
> 
> Nothing in dmesg.
> 
> This means the real root reason is somewhere deeper and reverting this
> commit just made it less likely to happen.

Thanks for information. Yeah, that makes somewhat more sense. Can you ever
see the failure if you disable CONFIG_TRANSPARENT_HUGEPAGE? Because your
findings still seem to indicate that there' some problem with page
migration and Alpha (added MM list to CC).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

