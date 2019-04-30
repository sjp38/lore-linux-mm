Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F06E1C04AA6
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:45:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7FE22173E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7FE22173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F57C6B0006; Tue, 30 Apr 2019 11:45:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A5706B0008; Tue, 30 Apr 2019 11:45:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36F056B000A; Tue, 30 Apr 2019 11:45:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDBA96B0006
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 11:45:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id q17so6609070eda.13
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:45:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:mail-followup-to:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=vfP2S2iii+DA6ccQoZJ7lIc8jHRYfYHozd7udFAc+Mg=;
        b=PJP8oruVJ3UM3N1i0i1Sh++BPCXIQqCuFIbZBGV7BQ4ppsEl01MfifPAJPnOT/w5+9
         f1dr32hHIithF90e0XXIGjfwT8kh0vUhbD+aSrFceoq4r5vWdgMrhe4qICACyHy4etEZ
         CZxamC5eFRI4kp8eBy3Hnp+QlJbc0RLht5L02n2Bj7PKXKd2QOUTOCAi+OgX7Oj0h4jm
         CfCDyIjQFeCUTV/SIMspdad57nLYDzso+mgT38/aat+q9THFsOt8irWNqh73RmD/N46j
         fjzGM1VIm271GxE0/r3WyKtaWv9U19Qy0spWfW7BqVSXKZhbPJvpN6dvQcKTkswujkER
         Dt1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
X-Gm-Message-State: APjAAAVcoJkHptjMcRK6MUaDQi8l4j3S6MhRJ2eGMekHEXIZQUDtmqdo
	hwQgpSfqrfBlQHUWBea6Q9cdlix4J6KEF+RoxAl5CUXBvknZVWkHclMNtZoi5X91CSOgeZFh/g8
	MpOTTID+Gr9diSSNQFL50obca3TxkpHlwW/ArFfSn1ZiZPS8crR0v1zmroZBq74NTlw==
X-Received: by 2002:a17:906:3fc4:: with SMTP id k4mr12750389ejj.166.1556639127340;
        Tue, 30 Apr 2019 08:45:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWGcfDdduDj44KRwGZapCDaVBzn8uOxfXZX3VIlGNDDiSkaihqf/9psxSeBec/UIFXmgk3
X-Received: by 2002:a17:906:3fc4:: with SMTP id k4mr12750339ejj.166.1556639125874;
        Tue, 30 Apr 2019 08:45:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556639125; cv=none;
        d=google.com; s=arc-20160816;
        b=ORffP+wgwjPgq5iwbVUwLxUzwXWZiUpkEOPemhx2MZ2JcmmOrTfRCqlcFbUvgC1bD7
         5WHkiFAnry9MF6ldq7H8/HotewLVj9hRtCD4iprjaF6xqXK5pdfcBwNwqgmi910w5p5a
         FfeA0EWt/hS7coJoIARgsGSYcGdjaaxUwU6TUe5WEK8a4SYQ9RdScFWFrH4r6BzMhzX6
         vbZjY/HYtXGbHPKXawDMsvUvqjeSyo/NUGKHlx3X/u1juaS56lmm4SUL9BncS0eW6Knx
         wMTalTuEhYO+Ui5XQvQ2z5LA33u6/YQvxV06o+8T1Ml8FOGW0NEv8wMDZoisZIogG1C4
         82Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:reply-to:message-id:subject:cc:to:from:date;
        bh=vfP2S2iii+DA6ccQoZJ7lIc8jHRYfYHozd7udFAc+Mg=;
        b=ueuY0tWYpQQrm/lAA/MMGTBcDK8RYlLLtXQwdL6SurHJ5l1uac1gmNRQpaDlwi7O3X
         SOIoIQpBmi82iuIhJGnpj1TrD4BAFD6fAhhLu2Eg64SOmvmq3ahCs3srjDKJ9LKwkpPn
         eCZKzIpUe/XZ+h6eldLNH9uR/jy76Ar6Wmidz71SzrY24Mqg5ovEE3zIM1kunscTuo3M
         r3cEiTYSN9plTa0rg+SVKV7uW64j2ro/m2ISj/kGd6QJ4mXIWy6TuUNJ6lQspYHI37EF
         vOKSFujPL/fn2u4cMVtEj114F08tVlnFtrlDAoSVj2kzabzKkhY8SrtCuM0tHSnfhALH
         80Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si1836005edg.97.2019.04.30.08.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 08:45:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dsterba@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=dsterba@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 47528AD94;
	Tue, 30 Apr 2019 15:45:25 +0000 (UTC)
Received: by ds.suse.cz (Postfix, from userid 10065)
	id 2CC4DDA88B; Tue, 30 Apr 2019 17:46:25 +0200 (CEST)
Date: Tue, 30 Apr 2019 17:46:23 +0200
From: David Sterba <dsterba@suse.cz>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 0/8] vfs: make immutable files actually immutable
Message-ID: <20190430154622.GA20156@twin.jikos.cz>
Reply-To: dsterba@suse.cz
Mail-Followup-To: dsterba@suse.cz,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-mm@kvack.org
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552786671.20411.6442426840435740050.stgit@magnolia>
User-Agent: Mutt/1.5.23.1 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:04:26PM -0700, Darrick J. Wong wrote:
> Hi all,
> 
> The chattr(1) manpage has this to say about the immutable bit that
> system administrators can set on files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> Given the clause about how the file 'cannot be modified', it is
> surprising that programs holding writable file descriptors can continue
> to write to and truncate files after the immutable flag has been set,
> but they cannot call other things such as utimes, fallocate, unlink,
> link, setxattr, or reflink.
> 
> Since the immutable flag is only settable by administrators, resolve
> this inconsistent behavior in favor of the documented behavior -- once
> the flag is set, the file cannot be modified, period.

The manual page leaves the case undefined, though the word 'modified'
can be interpreted in the same sense as 'mtime' ie. modifying the file
data. The enumerated file operations that don't work on an immutable
file suggest that it's more like the 'ctime',  ie. (state) changes are
forbidden.

Tthe patchset makes some sense, but it changes the semantics a bit. From
'not changed but still modified' to 'neither changed nor modified'. It
starts to sound like a word game, but I think both are often used
interchangeably in the language. See the changelog of 1/8 where you used
them in the other meaning regarding ctime and mtime.

I personally doubt there's a real use of the undefined case, though
something artificial like 'a process opens a fd, sets up file in a very
specific way, sets immutable and hands the fd to an unprivileged
process' can be made up. The overhead of the new checks seems to be
small so performance is not the concern here.

Overall, I don't see a strong reason for either semantics. As long as
it's documented possibly with some of the corner cases described in more
detail, fine.

