Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B917DC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D16C20862
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:41:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RX9dvSWs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D16C20862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE7CD6B0003; Tue, 21 May 2019 07:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C990C6B0006; Tue, 21 May 2019 07:41:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B60566B0007; Tue, 21 May 2019 07:41:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5D86B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:41:28 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id cc5so11198162plb.12
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:41:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=n5dWQ3Ja5NO1lr47hpp2L5Kch8Dt+AsS9vYvgJKkvHk=;
        b=ZOFQCrBTD/ZYgv+pQRrxeGdbs1mScQjattGrjg9cGrY3gBv+ffUanQmfWPbGkRvYyV
         isExRYXZByNVlYi20czQRM771TM/RQtKSodE18YzZF4pTmTw6aWOHHZZU2fO+VWp8LX9
         nQrYvS9QW7L4t1zKio6r1mX0BIE1KNzE5GxdOnQhH5bNoBOzTqIG4ixnR8K2NPe7vMui
         gDfGBdZh9Srx16aeuFmy+pRYR4h7VhaVEZU9bTgZXXwhOtGcexo1g+OosShMRUXIcwQc
         34IM9qJMSidt7CNSEsnVpaxPGu0nNrAFBDMSt8J5R0zkJ69eTrcNNSqdJSw6Z5Ka7zIE
         YObw==
X-Gm-Message-State: APjAAAV3obGWMxvVnOFQ2ScmehmwCMy1xPD476FwHXEgdAMaf9sfrEys
	V3BvmXZ/8i6aYAjX8QVagY1Z4qtyIjnXdMhXN9bZeEEv0D89W6e//McoNPO5V+HJ8J+8IqaENSb
	tY8z83H2Q09iwS9iU2XOiLzypJNLyYNKzgX9x6u4n+cVcsw9b4s3XLNTTso8m7W4=
X-Received: by 2002:a62:51c2:: with SMTP id f185mr26144456pfb.16.1558438888067;
        Tue, 21 May 2019 04:41:28 -0700 (PDT)
X-Received: by 2002:a62:51c2:: with SMTP id f185mr26144395pfb.16.1558438887313;
        Tue, 21 May 2019 04:41:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558438887; cv=none;
        d=google.com; s=arc-20160816;
        b=Ku88AABHHgb0ULOXX3vqXWwbJsnmbWReYLH9lKNEYqwvStn9Hw52152eRAnhPuhgXV
         ExcU65kSdeaOqKdFAPhwCoWmodcT0wQ3+z+NOH8aJv2MwC2inu2IstvukGhDMknZAgG1
         C94Cn6fD+97ACm3CAFVwfQApN2FmNw2muYVa3WLLqAxZGajzsnnSz4qiOlsdAGWtdHAI
         mrcLKIv2bD96O4VrGAjXkD5pm0Fu3/QkUej20aBBJQEGpfxlswAGE3w/hazzrZjxVcQ0
         csgaYW+J0vhN1gZUXYRVJMbMNvDCA3XCmYSLgp+VdHvbaCKTEKf/b65uSfeTgl4Db8y+
         iNPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=n5dWQ3Ja5NO1lr47hpp2L5Kch8Dt+AsS9vYvgJKkvHk=;
        b=0xF9K5TWF/yIq58Kcr8m/H0a+dLcOVzjf5d4cG9Qs1cJ44V5nP5XCMT55Y3ydFI4DU
         dUR0N7lv31p5+BqfnQxPVjA/ndjGRgAzZzqRupYFbwynVapSjxbteMHzeYz7Isg/XVSM
         COf2io/26rYnnNC1r5RKb5f0FYUhkE7Ca6gY1uZQk7M+JkJ4MndTh0ubuOxLVe/J5XR0
         B4WaIPOJ0qR3d4kYio++sPUaRd8R5Zi6la6/ifhV46Z77mt3vyy9UD8esaA+7sytyAUH
         JUzFdFm6N5+Oa7fmDVKp1+Pq8mwvIYeFUJWpxq+Kfq0cBe7nWS/UyVcFXjwAibMq1hUV
         S/mA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RX9dvSWs;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4sor1116185pgs.14.2019.05.21.04.41.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 04:41:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RX9dvSWs;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=n5dWQ3Ja5NO1lr47hpp2L5Kch8Dt+AsS9vYvgJKkvHk=;
        b=RX9dvSWsMT0l7VAW/j4tU2p4YOSU8QnbSoiM3l169YXHbFcQ1uK9668GmV+AwA/+u5
         ifhijxtDu7dfAS8sApbydMxP3I8eFKYT1/R/ziLipq7syDiLTsOdFZabpJw6Ag1HbVLH
         fTUPLUZJdQLg0HmFKSmMFBBKRSh0BJClZUpMspvYbpltnQ2FUCKbc98/YRG0scflh6fY
         HXoqWSLaE5eY9Q3dPj8fAr15H9lG/7A1d1xZhitqo2W/11qdbbR3hGgLfq/bMdYQFijz
         GUHTdtmMwo3x9/r5tyS4JCsKbTOv6hMj39iRmwt5DWMndG4vJRdrTaeokcaEQZtE0Xit
         MIBg==
X-Google-Smtp-Source: APXvYqxnxlMNwKQPfcTH3sQMedqBDlG7IiYvyS99EhYiMtaSNQNsgVFblj9Xg8+PqjERzjJTGTv/0g==
X-Received: by 2002:a63:2c4a:: with SMTP id s71mr64532589pgs.343.1558438886922;
        Tue, 21 May 2019 04:41:26 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id e12sm38745456pfl.122.2019.05.21.04.41.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 04:41:25 -0700 (PDT)
Date: Tue, 21 May 2019 20:41:20 +0900
From: Minchan Kim <minchan@kernel.org>
To: Christian Brauner <christian@brauner.io>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521114120.GJ219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com>
 <20190521113029.76iopljdicymghvq@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521113029.76iopljdicymghvq@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:30:32PM +0200, Christian Brauner wrote:
> On Tue, May 21, 2019 at 08:05:52PM +0900, Minchan Kim wrote:
> > On Tue, May 21, 2019 at 10:42:00AM +0200, Christian Brauner wrote:
> > > On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > > > - Background
> > > > 
> > > > The Android terminology used for forking a new process and starting an app
> > > > from scratch is a cold start, while resuming an existing app is a hot start.
> > > > While we continually try to improve the performance of cold starts, hot
> > > > starts will always be significantly less power hungry as well as faster so
> > > > we are trying to make hot start more likely than cold start.
> > > > 
> > > > To increase hot start, Android userspace manages the order that apps should
> > > > be killed in a process called ActivityManagerService. ActivityManagerService
> > > > tracks every Android app or service that the user could be interacting with
> > > > at any time and translates that into a ranked list for lmkd(low memory
> > > > killer daemon). They are likely to be killed by lmkd if the system has to
> > > > reclaim memory. In that sense they are similar to entries in any other cache.
> > > > Those apps are kept alive for opportunistic performance improvements but
> > > > those performance improvements will vary based on the memory requirements of
> > > > individual workloads.
> > > > 
> > > > - Problem
> > > > 
> > > > Naturally, cached apps were dominant consumers of memory on the system.
> > > > However, they were not significant consumers of swap even though they are
> > > > good candidate for swap. Under investigation, swapping out only begins
> > > > once the low zone watermark is hit and kswapd wakes up, but the overall
> > > > allocation rate in the system might trip lmkd thresholds and cause a cached
> > > > process to be killed(we measured performance swapping out vs. zapping the
> > > > memory by killing a process. Unsurprisingly, zapping is 10x times faster
> > > > even though we use zram which is much faster than real storage) so kill
> > > > from lmkd will often satisfy the high zone watermark, resulting in very
> > > > few pages actually being moved to swap.
> > > > 
> > > > - Approach
> > > > 
> > > > The approach we chose was to use a new interface to allow userspace to
> > > > proactively reclaim entire processes by leveraging platform information.
> > > > This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> > > > that are known to be cold from userspace and to avoid races with lmkd
> > > > by reclaiming apps as soon as they entered the cached state. Additionally,
> > > > it could provide many chances for platform to use much information to
> > > > optimize memory efficiency.
> > > > 
> > > > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > > > and MADV_FREE by adding non-destructive ways to gain some free memory
> > > > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > > > kernel that memory region is not currently needed and should be reclaimed
> > > > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > > > kernel that memory region is not currently needed and should be reclaimed
> > > > when memory pressure rises.
> > > > 
> > > > To achieve the goal, the patchset introduce two new options for madvise.
> > > > One is MADV_COOL which will deactive activated pages and the other is
> > > > MADV_COLD which will reclaim private pages instantly. These new options
> > > > complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> > > > gain some free memory space. MADV_COLD is similar to MADV_DONTNEED in a way
> > > > that it hints the kernel that memory region is not currently needed and
> > > > should be reclaimed immediately; MADV_COOL is similar to MADV_FREE in a way
> > > > that it hints the kernel that memory region is not currently needed and
> > > > should be reclaimed when memory pressure rises.
> > > > 
> > > > This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> > > > information required to make the reclaim decision is not known to the app.
> > > > Instead, it is known to a centralized userspace daemon, and that daemon
> > > > must be able to initiate reclaim on its own without any app involvement.
> > > > To solve the concern, this patch introduces new syscall -
> > > > 
> > > > 	struct pr_madvise_param {
> > > > 		int size;
> > > > 		const struct iovec *vec;
> > > > 	}
> > > > 
> > > > 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
> > > > 				struct pr_madvise_param *restuls,
> > > > 				struct pr_madvise_param *ranges,
> > > > 				unsigned long flags);
> > > > 
> > > > The syscall get pidfd to give hints to external process and provides
> > > > pair of result/ranges vector arguments so that it could give several
> > > > hints to each address range all at once.
> > > > 
> > > > I guess others have different ideas about the naming of syscall and options
> > > > so feel free to suggest better naming.
> > > 
> > > Yes, all new syscalls making use of pidfds should be named
> > > pidfd_<action>. So please make this pidfd_madvise.
> > 
> > I don't have any particular preference but just wondering why pidfd is
> > so special to have it as prefix of system call name.
> 
> It's a whole new API to address processes. We already have
> clone(CLONE_PIDFD) and pidfd_send_signal() as you have seen since you
> exported pidfd_to_pid(). And we're going to have pidfd_open(). Your
> syscall works only with pidfds so it's tied to this api as well so it
> should follow the naming scheme. This also makes life easier for
> userspace and is consistent.

Okay. I will change the API name at next revision.
Thanks.

