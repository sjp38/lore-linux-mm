Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 083F9C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:20:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D626218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:20:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Od1xhSlj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D626218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11B108E0002; Mon, 18 Feb 2019 03:20:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CA5B8E0001; Mon, 18 Feb 2019 03:20:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F22258E0002; Mon, 18 Feb 2019 03:20:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8B008E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:20:34 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id d17so4278124pls.2
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:20:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=smQ3UZLScYHvuL/U/au9eTzJZ5+ZHSry0nos0pW1Ac8=;
        b=Im/xWg8urq2/6Tc/wCNK3pTQHK60oDqyRrXRFJgER6EmHBDSrR8mhBeBPU3KAGyTpb
         4Xtk/dDmaqIRubui1ppoxQyRfaliPIkQ4gV/7QahQiTmFPy+kYAWwsJq7Hic2lAbMrGx
         q0G6aaXIk/qRPT9KYHTI6cUNpKAdqNLb1z3BwmLGpIH+TKMs0L9CxRPyT3m5LEpjn2Ys
         ABBhvVqLZ86OdUBo9BYp/Rj598Ttbs3p4vWP9uoZpNUpAqbRRpLB6f+QGXKm7R9Q64eO
         JP7cwVtJwwyMTBbNEYuve89FVJx3tiHt+pkKHRlNtqKPgKupnuVjwG68HZSwVjDEiY71
         +iWA==
X-Gm-Message-State: AHQUAuabi8NDUp7rqaaCdPdvayT5I5ZwZj2yi7lK8UztHQmhC9kzU0oN
	VG3g1NPKXsRUUX32DkjaLbcGpAuWcLuN/rV2UgOz/SJImVb6LqQEdiETKXu4Mly1Rioq44Kr3y/
	zr0+MC4laRhgNW3GJsJ+J5EZ/2k3W/9ZhpLjNFocree/JUNcY5BeI75NJpskdkd9sD/1bYMjXk2
	bvb9uBccsQ13M9+dnlIwN0yTGgqBwM3tD0V7kCkrquJXIIeFTtVzjtQqE0ORURGc5tMAdl8v977
	9QAkq7m5geHLnHMJ2aU+rqQdLX35ySANb8u3P1ZFJMjSxNW3qinmyc3wOZ5cD23WsNWFen8Swbj
	SJcOZrtqsvwfmUBh61OthJtSpdjFtYGJIfRsdVojAwfAq++Jv4uUea634KKRs12ORcqqcvnwQA=
	=
X-Received: by 2002:a17:902:a514:: with SMTP id s20mr13824970plq.242.1550478034275;
        Mon, 18 Feb 2019 00:20:34 -0800 (PST)
X-Received: by 2002:a17:902:a514:: with SMTP id s20mr13824931plq.242.1550478033541;
        Mon, 18 Feb 2019 00:20:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478033; cv=none;
        d=google.com; s=arc-20160816;
        b=lq5uepUdN32Ql56PK5nqYYQT/Ll72nkCmmzxuThO7+tMuN9Cc4VuxFkt4fA2z1NbWX
         6plx8GoSiCSAg2o2yRAH3keUw1S36hBNqAZfgPNRlum66Fubxd2K9JXhf1ORA5zwE7l4
         aN8NB9xeceyz7qSTMQPRiSaDIYe+LxYXo2fkcVEXSgsma8Q9X8EysZ53ho2ce8Ae0vrc
         K53TRqnStVXbCsn24gcvG1WVrX9PsGVSI2bfShJ9lQ2PODnVvZfFS02BROMQdgSOFHlF
         AO6SaAgkJSIbkWyuFVbu/3y45WDORAtP7UqXMZ9k5juWFyXK7u4L1EsNkAyvVTKEA5Kj
         F7bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=smQ3UZLScYHvuL/U/au9eTzJZ5+ZHSry0nos0pW1Ac8=;
        b=vdc1tcCcQeM9y3jK22B+0Jl5NWf70RGKWBdhtVnZVOswuuqT8UM9aeKI2ecW1sahGe
         kwsQf0uwB3Pv1odYchSGFKcHWUiPPSJ4vthL0VzfQOxTmW/ykiVmrIcoUMKXzWvJEse+
         45znSSsJMnsaTWc8FnihDaXl7Z8KdFBpSK/3uL+0HzihX6NiFgKFPrv7YkkYqWWSXkfS
         kZdKXwr5n5A3Kz8SnJ4o3StfAF0NJlOo03xFeiS5ZwBeGH6Y8Xr5z23dtafG7sqh1yBJ
         b91v7kPTf6bBleKalQBu4KdkMjT8W0zwXLM+sxTbWpy+PxSkrU9Ydz5FJPGyLLlNdFeG
         DjzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Od1xhSlj;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i20sor1816413pgj.36.2019.02.18.00.20.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 00:20:33 -0800 (PST)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Od1xhSlj;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=smQ3UZLScYHvuL/U/au9eTzJZ5+ZHSry0nos0pW1Ac8=;
        b=Od1xhSljbWo3lxm8juCFdcBlxaiHw1ZEjfyL0pHfxUmCLSsd1hn2KPoNWCgczS3I6w
         gWGMmNp0+ZVap4NtrZHLS1nhFeAgML7oRffvfXsLt+KSxzTgpogIKsHcYQC7Cqvn0TEC
         OOzPqI8D3Vttbqwu7wGqNJEKzU3YbpgGjgVhY7EWV2DY5lCGeBxfSEx7O309AaaohDcO
         ej859s2vNfLRttVJ5SzQs6uXmim244ihj/Rz/Bjdi/1FP2RHcC/UKCThxDmynmyF5Suo
         u450ETx3MTHnDZpcZQLopLTq2+sE4OuRyMjvdBuOCNTuMswIC4gCFksFULypR364s2k8
         GSGQ==
X-Google-Smtp-Source: AHgI3Iav4jqBKezlgwNb3JzRYCs5r7JAWnEaRBCpeQQShzGNANjFafBIxhvWEUa4FSBUB4T5kF5I3Q==
X-Received: by 2002:a63:5964:: with SMTP id j36mr17725124pgm.210.1550478032951;
        Mon, 18 Feb 2019 00:20:32 -0800 (PST)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id q75sm20865180pfa.38.2019.02.18.00.20.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 00:20:31 -0800 (PST)
Date: Mon, 18 Feb 2019 17:20:26 +0900
From: Minchan Kim <minchan@kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190218082026.GA88360@google.com>
References: <20190213112900.33963-1-minchan@kernel.org>
 <20190213133624.GB9460@kroah.com>
 <20190214072352.GA15820@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214072352.GA15820@google.com>
User-Agent: Mutt/1.10.1+60 (6df12dc1) (2018-08-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 04:23:52PM +0900, Minchan Kim wrote:
> On Wed, Feb 13, 2019 at 02:36:24PM +0100, Greg KH wrote:
> > On Wed, Feb 13, 2019 at 08:29:00PM +0900, Minchan Kim wrote:
> > > [1] was backported to v4.9 stable tree but it introduces pgtable
> > > memory leak because with fault retrial, preallocated pagetable
> > > could be leaked in second iteration.
> > > To fix the problem, this patch backport [2].
> > > 
> > > [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> > 
> > This is really commit 63f3655f9501 ("mm, memcg: fix reclaim deadlock
> > with writeback") which was in 4.9.152, 4.14.94, 4.19.16, and 4.20.3 as
> > well as 5.0-rc2.
> 
> Since 4.10, we has [2] so it should be okay other (tree > 4.10)
> 
> > 
> > > [2] b0b9b3df27d10, mm: stop leaking PageTables
> > 
> > This commit was in 4.10, so I am guessing that this really is just a
> > backport of that commit?
> 
> Yub.
> 
> > 
> > If so, it's not the full backport, why not take the whole thing?  Why
> > only cherry-pick one chunk of it?  Why do we not need the other parts?
> 
> Because [2] actually aims for fixing [3] which was introduced at 4.10.
> Since then, [1] relies on the chunk I sent. Thus we don't need other part
> for 4.9.
> 
> [3] 953c66c2b22a ("mm: THP page cache support for ppc64")

Hi Greg,

Any chance to look into this patch?

