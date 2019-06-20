Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B33EC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1FD42083B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:22:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1FD42083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CD246B0005; Thu, 20 Jun 2019 13:22:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A3E58E0002; Thu, 20 Jun 2019 13:22:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B8978E0001; Thu, 20 Jun 2019 13:22:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9E26B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:22:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z5so4490220qth.15
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:22:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ANxCRHapZpcmauP58fFGvA44oGdcasiueMrytFA9ELA=;
        b=IQc5ox6s+TPKlIO+LpIlkM5y/LYCuGwacyVRYIN+u1FwtFs5/7xvsIks9AZJmeLwQ6
         Amfvb5SzsCILtslj7oQhAiKuXu1IOO4kLTfUFeEXDcDKhswJMBS0Me1eRRVapPO8NL8f
         G0YnWL7Hmjy1xh5EahjRlVVy46FDYKyLHedbtI4u/2CELaGuUmNT4tnkR3Kdd4wXmcZv
         m/mfL/G0dHorlzZteouwmbHvazRgUCAtEIj92WVgkMAa8Yn7s7tWe3em4br3/5Z5hbda
         hNCdMRGBpJJzNcmgiKi+dWRuLEzKLeqAu8leaP4AyNO0B5Bn7nJMkm+6ki60ukBHoijP
         TMcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAXRy1jGO0gFthjlH507HR1BniqHY4VAz29HxY8lp/WKFTf8giaO
	9NtWAlZfHowcedOXSZqDNz9B5iKTRauBp11DvSVXwJ1bqgQY9tv312jEH5quCUI9XbMqhVGb3z+
	URLK0WzN9Snu2TvjImnL7PKIefYHy+gTioE9BdTm1KvhLpaVqXmFjo9sqeqm8uYagzQ==
X-Received: by 2002:aed:3944:: with SMTP id l62mr19287883qte.34.1561051331806;
        Thu, 20 Jun 2019 10:22:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6ZbcDjaIxMEiEVWw+2yZiCXahIBDVodK08jxuccWl70sw6v7aMZ8sxO3hOf1krwyjcQma
X-Received: by 2002:aed:3944:: with SMTP id l62mr19287829qte.34.1561051331171;
        Thu, 20 Jun 2019 10:22:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561051331; cv=none;
        d=google.com; s=arc-20160816;
        b=lwO3Df1bhbGCxoNvCWg8dj2I7XAVMj/s8ZaMgrdj0Qu59CJeCgOtj/u44QYVguQPJT
         homo81rySF/Y1PDc2/BOA/lKMjYczDEUMM6M3lI3rrNMn2bHyV46g/SpRsrLwYzmJdP7
         DMkgZgKuvIvAZTrYSmjGeUdeyhJoTrAAI4SZXdDm8ZTqtsTJiWm7SyOmtEQm7jr8DCUz
         wM1Bg7O0V4W/ZvQ6h60AntbQttquhfGN2jfsy4ay9HePWVqX3TTET7KA+1dgrVKlR+X8
         zCC71n+HhRgK3Qh+hEnxoSyTfaLiSI5JhfXe66VUCDPOre32UD5pgn+bS9cpDUzrnUbM
         TA+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=ANxCRHapZpcmauP58fFGvA44oGdcasiueMrytFA9ELA=;
        b=a3qbgqpd4uE1kll8EqmUiqu1hd/pOzGTSLJd8g47yHUFNPUOP9ReAusDvTztdWjldH
         6Llbu8pthGQjaOlqQcYE1Pj93+aw8hNQUEiM9o9Hi8MR1ElGTVoI67KanIjIzMatMZVk
         eMAazISXREWA141DERjUlh4jfZeoBBMDqP8OgIR91b/kQ1bOc5aaORPAqeNh98IfVXd1
         KinD6ZNQR8jmE8Nz7SdgTZa2Ey9yoI9chn8GjPU7qEJey4gAPrqlPG907tAu3e1oEcW/
         JsMLWOCIUQWAs/ivRUKIex9oRAhqQ1Mtx4pXcom5n8S+RfWZTZyGyTSrSgna0vQeE9tK
         8tLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id f19si150583qtk.184.2019.06.20.10.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:22:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (guestnat-104-133-0-109.corp.google.com [104.133.0.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5KHM8mu014348
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 13:22:09 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 528DC420484; Thu, 20 Jun 2019 13:22:08 -0400 (EDT)
Date: Thu, 20 Jun 2019 13:22:08 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: Ross Zwisler <zwisler@google.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <zwisler@chromium.org>,
        linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
        Justin TerAvest <teravest@google.com>
Subject: Re: [PATCH 2/3] jbd2: introduce jbd2_inode dirty range scoping
Message-ID: <20190620172208.GB4650@mit.edu>
Mail-Followup-To: Theodore Ts'o <tytso@mit.edu>,
	Ross Zwisler <zwisler@google.com>, Jan Kara <jack@suse.cz>,
	Ross Zwisler <zwisler@chromium.org>, linux-kernel@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>
References: <20190619172156.105508-1-zwisler@google.com>
 <20190619172156.105508-3-zwisler@google.com>
 <20190620110454.GL13630@quack2.suse.cz>
 <20190620150911.GA4488@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620150911.GA4488@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000071, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 09:09:11AM -0600, Ross Zwisler wrote:
> We could definitely keep separate dirty ranges for each of the current and
> next transaction.  I think the case where you would see a difference would be
> if you had multiple transactions in a row which grew the dirty range for a
> given jbd2_inode, and then had a random I/O workload which kept dirtying pages
> inside that enlarged dirty range.
> 
> I'm not sure how often this type of workload would be a problem.  For the
> workloads I've been testing which purely append to the inode, having a single
> dirty range per jbd2_inode is sufficient.

My inclination would be to keep things simple for now, unless we have
a real workload that tickles this.  In the long run I'm hoping to
remove the need to do writebacks from the journal thread altogether,
by always updating the metadata blocks *after* the I/O completes,
instead of before we submit the I/O.

					- Ted

