Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99986C04AAA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BDEF2133F
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:16:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eL3QpXJR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BDEF2133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F34E86B027D; Mon, 13 May 2019 11:16:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE5EA6B027E; Mon, 13 May 2019 11:16:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAF196B027F; Mon, 13 May 2019 11:16:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF346B027D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:16:03 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id d30so8613783wrb.2
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:16:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bYuqnNx8h6Iw6jTM353AK1PTjYrbJH6v8Q1fEGBhMmc=;
        b=SWJoAk7tzB9GZh6uQ5/Bua4ZKgUOwqdcjhepCWoktD119QZIHd4Rq3VkUHbAuIeeLw
         J5hvR8Sg+lB/4fzVXE/0gtSKPQc+g3Nmhk15rICc29SPGMSxK3GTFEDxZ+Qp0LWkehTW
         QlVWZiSZgh26fO8FtezdBDDqS1GhBiMt1yrx8Qb1eEi0bJgm482V9WVhYDivewCUbUkh
         x19unIp+eaShH1fn/ni3rJ6hUenSf306Ng3pkve+fzvrudTuDj6byJenxd8dYlVjBa6X
         42T/57v5/B4eJadmH5WpOAWExJJ5/PpRhIpNRDf41CYqriQdChsCH6XivjJNGEY5Mqyu
         LjsA==
X-Gm-Message-State: APjAAAXDwWM5x7uMtyKiX373hsc3xDS9mofivr1LWrrp5b2QwwGDc3NR
	2NTfOS5qMvQFMrOF8w1dg8KSAsSsj0HYB/SwWK+U2IVX7a35fZMqD54mPxac/8t0e5WAU1YItoS
	zmpKH64gGaUbAXzRKv0mIKxg8X7+d8tObxv2ebiAxnEj7MADQqifc4iWxJhm68QyWyw==
X-Received: by 2002:a05:600c:22c5:: with SMTP id 5mr15366433wmg.129.1557760563166;
        Mon, 13 May 2019 08:16:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlEGYjm8Pn3x+iBZAjWquatyk1vVAGoQ/COs2+qHv7pHaA8ZsCllR9ay6ms4PoNM/beGqi
X-Received: by 2002:a05:600c:22c5:: with SMTP id 5mr15366386wmg.129.1557760562368;
        Mon, 13 May 2019 08:16:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557760562; cv=none;
        d=google.com; s=arc-20160816;
        b=Z0rGkgctDQ8QkcudMBTEY5xqImdP3MaHMvlYSn+8tehrAA/bYTGZlnCIrNyjRgGqDl
         ey9AdrASM8IgqZVZ/tAON8LCgzKrAxnaIBFFx0MflXFgrZUf0YB+BN2wNdRNiKVbvoYQ
         gMsRABv8mB9lqI0hDcE4xzzh0TMH1S7FEKT5fdkw1qugj1PViqPhlTBN/DfpyRxrn8g7
         j0hMCgGNS7CzamscFNH0tzzfeONkEU6gqXhqRFoTwSIajJ/lwgXFkidhJFZqhN5BiAk+
         DM7+8Nz8frqGhvGu81x6J3DifqS0IRq+B73eJD/f9WDmDSb/a3GoYxfy90T8rnhB06QO
         NxHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bYuqnNx8h6Iw6jTM353AK1PTjYrbJH6v8Q1fEGBhMmc=;
        b=yuTOQIViCH1xWQVDqvGqp5uqkLGLqIgbdKOmkbtMoKmnvDGSX7UH9aYR2/KrfCFiXS
         QWouucwdG0k8YQoRrbPi647/Lu1btvWUZUsS6165Z28FYYxtf+e76wALkDbCH06WfI5H
         lIkBd/7tPFd871ih+L08QIM/HxEraye7szl0xw/Kiep5fhn3cfILTQ4SMBQE9T0kfbt3
         M0ex5/kRwbTpkcaYKIM9wUHLSUzEhTiYVsIdJcc9llRUnQPzoxs8Y52sWQpPXjoDysuL
         nwi+iNVgYqwJNNF0L4An1Zn5AQ8S6QYjIx+FLjHVrR/VdmH40cPdRMOJH+VmKqH/QWpE
         KbEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=eL3QpXJR;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b190si5487850wmd.129.2019.05.13.08.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 08:16:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=eL3QpXJR;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bYuqnNx8h6Iw6jTM353AK1PTjYrbJH6v8Q1fEGBhMmc=; b=eL3QpXJRQjwXezlHRxfCBxm8e
	Kc0EnqgYz91km3dBTclXTRds68PSLigiCzchSr4QK7JAmBnZBEThmffHXoSPR3XcYY98+gWsAfb7B
	mVu231w+Kk7wKcEDyhIvIZwAl5JUwsQ5DoGIggNvPnlR84ITHS7vZxyFaFoZV4NmvCrxYruTH/WyL
	YhcBvIYRTrAC5P39CLL7HXC6Vq2TCbZVcgm4ZWdjcyAaIVsRCF0hnYiDpaXdTQ8WAPenSAHTiChs7
	qYS9xx6BwvqnqKRzs/ZdifIKkAgPBD1itn4DTe/691rEVSvUK1HR8eVTeI1ph1XacQSWx4AZ72U8D
	IQ4NvMS6Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQCgB-00082o-SH; Mon, 13 May 2019 15:15:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A89E92029F877; Mon, 13 May 2019 17:15:50 +0200 (CEST)
Date: Mon, 13 May 2019 17:15:50 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
	mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com
Subject: Re: [RFC KVM 01/27] kernel: Export memory-management symbols
 required for KVM address space isolation
Message-ID: <20190513151550.GZ2589@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-2-git-send-email-alexandre.chartre@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557758315-12667-2-git-send-email-alexandre.chartre@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000010, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 04:38:09PM +0200, Alexandre Chartre wrote:
> From: Liran Alon <liran.alon@oracle.com>
> 
> Export symbols needed to create, manage, populate and switch
> a mm from a kernel module (kvm in this case).
> 
> This is a hacky way for now to start.
> This should be changed to some suitable memory-management API.

This should not be exported at all, ever, end of story.

Modules do not get to play with address spaces like that.

