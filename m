Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0F8DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FD4D218D3
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:33:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RLafrqVV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FD4D218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E57608E0003; Mon, 18 Feb 2019 03:33:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E064D8E0001; Mon, 18 Feb 2019 03:33:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF6EB8E0003; Mon, 18 Feb 2019 03:33:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 909A68E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:33:39 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id z1so1323523pln.11
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:33:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qqR87h0KOe1UhkI+Ei87wwDLpvMOPa0NFq/FdDHBvgc=;
        b=uXUAE8DuCKuvxGJ0ZL0QKviiBwY5LVY7TGjcicS5e9Vm0vh1lB+T0SJxq4NBsFbinI
         2bfE2VkECZdNWvHbUC3onxxyzZl+JAStQykeZ8IPkvzlUT8sdtYr55IDmV05Td1o85c2
         CfjUFarPDlXDXOllCl8D7JEySC0IrJCrrxoQVt/lEOXQUOe1YvfWko5pVaIByPOML0DA
         9faCvdva4KmFC5tDEn/+jvLObgH/vcN1H3JTe8seElEWc2VCaeNMFfGrLb+3FePnPdBk
         W7qDCrz3d6+7YUPPfFQp9M0pCqBG1jhnzCTTSXqBXm5TtZILoBfhrPTsDtu9zpbBqJVO
         07Dg==
X-Gm-Message-State: AHQUAuaW02Mp+OcEHAf04ThhUNrumQg1vk4pzZ/N4wOvJ4B/t/7V/o7e
	A7AkVEB2exBWthKb9N9UAXRXJQmzvEz4rQsJsjzbVUtdHvNscxx8b3u9Xo3jp76yXSXpMXZWedU
	lIGWZGXiqf1AYo/k/9F92Z2+H4sNs9RGVgipO8/XHx3D2aBwRhfkggbra2ig7Spw=
X-Received: by 2002:a63:fb42:: with SMTP id w2mr17990701pgj.408.1550478819236;
        Mon, 18 Feb 2019 00:33:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbP/9qAPIS78m6XE5DtNBh+ntiXWWpKj6+y89qAeev4fCxf4w2+N+aSVTD5R/MtdLlczKeq
X-Received: by 2002:a63:fb42:: with SMTP id w2mr17990664pgj.408.1550478818591;
        Mon, 18 Feb 2019 00:33:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478818; cv=none;
        d=google.com; s=arc-20160816;
        b=KNUECYmDlhkXhx2ygxOsgfmNB+6wYye6mjSZTvTNVhCA0O6ZKgr6tIrZN7zVAT/+yo
         0bvhc4xzMzJXEv798crL554dkFxWwV9oT9VP3sZPUJL80AVsFfNZb71wG0AdSck6H+V3
         rdZaKHqBwncszTaLoUO9MRJVayuVI+axgyxvYtsfYpH5nSSoZ+VR6QJ/+F5tasopGoJ/
         CX7ZcLwPZlMCAFyrhd780MpKlyuDt7ftJiTZ5gc797j0Z/Nw4Jciy26e+q0l3zI5A93P
         8thRnDmxTIfk1xFtWQLrlRioJMxO80JDFE6g2VGOYpa6WR1LZlTFggiS/WyJ/o/koLPJ
         653A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qqR87h0KOe1UhkI+Ei87wwDLpvMOPa0NFq/FdDHBvgc=;
        b=gUmt2nANY3hRjSTmJ5uJzoPjp0JcpW57HRWkF8/fC+LsSlnHtlxqHTuM9JZrbk1F9z
         0LF6/971k6La2083oMPccRz/6IWkvhnXQPp+xsyl4DBHiJQ9T9J2dzhzOCnlqhrFQDhw
         9W9lgFA2dslQqpKwAAx7zEyT3IMPmkKD/IzQ4xTab9AJYv/idIp4Ye4S0/S4OJvd346G
         vV8zR75QeRWovZKgY/ngRAeUdk9DuPWe7wEUJF6YbNsKjZEdlxip7pXrt5xZmCSLRTXg
         YKRUEmhlOcus7SRPPbUUACed+v0ZtTCDYLvIlTveoSHmY5z/3XjkWXMnw0jPjTQUUoTX
         uDGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RLafrqVV;
       spf=pass (google.com: domain of srs0=7u7d=qz=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=7u7d=QZ=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a6si12773590pgc.137.2019.02.18.00.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:33:38 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=7u7d=qz=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RLafrqVV;
       spf=pass (google.com: domain of srs0=7u7d=qz=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=7u7d=QZ=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C1236218C3;
	Mon, 18 Feb 2019 08:33:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550478818;
	bh=CmXX9u5peyTA7EY0dDdEIb7WHNenqZvfOqTAvpjVwXc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=RLafrqVV4dLMbhPYz/kTnY+LblV/jWBtX4hceg81/BRLQ74bMnsXMFmKQzCNEp5ke
	 s/lqMq8imyrGvUkQQ5VX1UvQFM6YDLhPnOHB778K3tKIReBmdKfxg3ayWJQGDArhUs
	 3h1ivAwjIOHWWoAA0p0MKnmbolS/ysLOra+r+2hg=
Date: Mon, 18 Feb 2019 09:33:35 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190218083335.GB20069@kroah.com>
References: <20190213112900.33963-1-minchan@kernel.org>
 <20190213133624.GB9460@kroah.com>
 <20190214072352.GA15820@google.com>
 <20190218082026.GA88360@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218082026.GA88360@google.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 05:20:26PM +0900, Minchan Kim wrote:
> On Thu, Feb 14, 2019 at 04:23:52PM +0900, Minchan Kim wrote:
> > On Wed, Feb 13, 2019 at 02:36:24PM +0100, Greg KH wrote:
> > > On Wed, Feb 13, 2019 at 08:29:00PM +0900, Minchan Kim wrote:
> > > > [1] was backported to v4.9 stable tree but it introduces pgtable
> > > > memory leak because with fault retrial, preallocated pagetable
> > > > could be leaked in second iteration.
> > > > To fix the problem, this patch backport [2].
> > > > 
> > > > [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> > > 
> > > This is really commit 63f3655f9501 ("mm, memcg: fix reclaim deadlock
> > > with writeback") which was in 4.9.152, 4.14.94, 4.19.16, and 4.20.3 as
> > > well as 5.0-rc2.
> > 
> > Since 4.10, we has [2] so it should be okay other (tree > 4.10)
> > 
> > > 
> > > > [2] b0b9b3df27d10, mm: stop leaking PageTables
> > > 
> > > This commit was in 4.10, so I am guessing that this really is just a
> > > backport of that commit?
> > 
> > Yub.
> > 
> > > 
> > > If so, it's not the full backport, why not take the whole thing?  Why
> > > only cherry-pick one chunk of it?  Why do we not need the other parts?
> > 
> > Because [2] actually aims for fixing [3] which was introduced at 4.10.
> > Since then, [1] relies on the chunk I sent. Thus we don't need other part
> > for 4.9.
> > 
> > [3] 953c66c2b22a ("mm: THP page cache support for ppc64")
> 
> Hi Greg,
> 
> Any chance to look into this patch?

You sent it on Thursday, it is Monday, I tried to actually take the
weekend off :)

It's in my queue, relax, it has good company with a few other hundred
stable patches being requested...

greg k-h

