Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C575FC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90D56214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:20:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90D56214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 315446B0005; Thu, 18 Apr 2019 15:20:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C3886B0006; Thu, 18 Apr 2019 15:20:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DA826B0007; Thu, 18 Apr 2019 15:20:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4A886B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:20:06 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id q16so2817399wrr.22
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:20:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=0gF5wMwYjHekDDpQMXiZeHs4LyorpTAzqryNxtdpgSg=;
        b=qnn+Y01iqbVTVq4m24KAQNax5A4ZK6jL3iRR4OZpaHctEGg+RrXi46a3VZ/50zMF1H
         oiWsy7mYB3Cqw2ihPryCU3N1HseofURSsbzjDN2WsI0Jlihr6jG2thuSKsXlhEXPxWwm
         CXc0Ddo2isBOUiXSmzZuoEna3ddXnGCHmgzjLpB9bKJ3KiuX8O0GdNgJaLCVQWquegta
         y1b+3DBrs8zwgnSv90pJwEBDWkD6+DRwXxMXShjJ4ySmfwq/XlBA+WA1IQh2nAnwM1lW
         g5tB/xeJ8qQ8b+QbStGKl4sHCtLqlP//T+c4YPikYcoC2gUPc1zZRrmSCB5HtrImwvj1
         Ibdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAW+7KK9IGtPyLjv2lNGPrq4apGiEMLIuPMjkTKQmSvZo7cr+dOl
	z7jfVYnSjXuoX3YSRRk3ukw5/aPz8gp/W2yZssx3qC3p9gjOdg6JKDWEAYP5dX44V7A/OVVUOGd
	Z4LXSQ+CAupmCcJpQJd0FE9O39wvBdcYmsfkMBhB8sjx2rRm3p5y8dpBvH1hc6zphxA==
X-Received: by 2002:a05:600c:28d:: with SMTP id 13mr4386848wmk.82.1555615206270;
        Thu, 18 Apr 2019 12:20:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPH2uzWwzNG+mYUjLiaM3jp7jqCRF5yhbHc7/vH9KzcsRK+4CKny2ufe1PcI7zDMtcEHGM
X-Received: by 2002:a05:600c:28d:: with SMTP id 13mr4386816wmk.82.1555615205459;
        Thu, 18 Apr 2019 12:20:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555615205; cv=none;
        d=google.com; s=arc-20160816;
        b=VPoj6dx+9Uz1ZSsHCwsYZV9TfPBOOBmG5+jgWGQ20yJT/fX2ysWBLTVmm+CBqdDIHx
         nVFJhqMr2Ge+acIWT8a9cDZ27+Rzi2okfkRP/hZmy1vK5jbLGa+3X/f9/p8l8pWGlH86
         dZRcjd4obBmUDx4JY47YmO4DDT8C0dv3JDyi5HQOVVcqODVoctG0upxifTuR9RArcYFO
         RnzeAMlkzNSB7rumBA09PCSB4TDIYyKuPTZH/cMQAsstHds0D0KM3hkfUpXpQxXVPRQq
         SJKNiOzVaOeDLaSb72PMH+U9daI0dg6Txv57geo4NueNvnBgWwWumxxIZVaMwRj8TlNi
         MPWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=0gF5wMwYjHekDDpQMXiZeHs4LyorpTAzqryNxtdpgSg=;
        b=gvaspTVqf5ItJ5dsJVZoL490hcjla62v8+bcdKY7HjlHmIp2i2pL6NTAviFPxBOEN/
         C/ZTj8dp32WHGFd7IKhU+4RWXjPOpKneW1uzOpU+fIl95AnhQydVCb6LL2PR4OgUqM1F
         O7X9IKRtIftea3ZozvI4Ub8wNSIskPs9e/dzDCiVgnXeZaqPhMlYwWcq8lBdH1MGCIBh
         LVaAjwO65f2ZU9g8ayJfuBnOmpa6KpSf7Pyofm/6fQlUv9IhnI1cbz0IhSYHHjoCE6kB
         6pPYGCpsl8aABSGyDAMfmzAMtuDf6EsVeBdMRm3tA500jxNZFHGYzc3uuoB1d35X2uTS
         /aag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h10si2382458wre.404.2019.04.18.12.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 12:20:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hHCZZ-000378-0T; Thu, 18 Apr 2019 21:19:49 +0200
Date: Thu, 18 Apr 2019 21:19:48 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Dave Hansen <dave.hansen@intel.com>
cc: Sasha Levin <sashal@kernel.org>, 
    tip-bot for Dave Hansen <tipbot@zytor.com>, 
    linux-tip-commits@vger.kernel.org, dave.hansen@linux.intel.com, 
    mhocko@suse.com, Vlastimil Babka <vbabka@suse.cz>, 
    Andy Lutomirski <luto@amacapital.net>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    stable@vger.kernel.org
Subject: Re: [tip:x86/urgent] x86/mpx: Fix recursive munmap() corruption
In-Reply-To: <09aa9f89-14e1-a188-057b-592e2fc845e6@intel.com>
Message-ID: <alpine.DEB.2.21.1904182118570.3174@nanos.tec.linutronix.de>
References: <tip-508b8482ea2227ba8695d1cf8311166a455c2ae0@git.kernel.org> <20190418182927.A78AB217D7@mail.kernel.org> <09aa9f89-14e1-a188-057b-592e2fc845e6@intel.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019, Dave Hansen wrote:

> On 4/18/19 11:29 AM, Sasha Levin wrote:
> > This commit has been processed because it contains a "Fixes:" tag,
> > fixing commit: 1de4fa14ee25 x86, mpx: Cleanup unused bound tables.
> > 
> > The bot has tested the following trees: v5.0.8, v4.19.35, v4.14.112, v4.9.169, v4.4.178.
> > 
> > v5.0.8: Build OK!
> > v4.19.35: Failed to apply! Possible dependencies:
> >     dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
> 
> I probably should have looked more closely at the state of the code
> before dd2283f2605e.  A more correct Fixes: would probably have referred
> to dd2283f2605e.  *It* appears to be the root cause rather than the
> original MPX code that I called out.
> 
> The pre-dd2283f2605e code does this:
> 
> >         /*
> >          * Remove the vma's, and unmap the actual pages
> >          */
> >         detach_vmas_to_be_unmapped(mm, vma, prev, end);
> >         unmap_region(mm, vma, prev, start, end);
> > 
> >         arch_unmap(mm, vma, start, end);
> > 
> >         /* Fix up all other VM information */
> >         remove_vma_list(mm, vma);
> 
> But, this is actually safe.  arch_unmap() can't see 'vma' in the rbtree
> because it's been detached, so it can't do anything to 'vma' that might
> be unsafe for remove_vma_list()'s use of 'vma'.	
> 
> The bug in dd2283f2605e was moving unmap_region() to the after arch_unmap().
> 
> I confirmed this by running the reproducer on v4.19.35.  It did not
> trigger anything there, even with a bunch of debugging enabled which
> detected the issue in 5.0.

I'l amend the commit to avoid further confusion.

Thanks,

	tglx

