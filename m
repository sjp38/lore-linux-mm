Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42A09C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 01:53:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0841218E2
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 01:53:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JUvjG7dL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0841218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F7E46B0003; Thu, 21 Mar 2019 21:53:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 381016B0006; Thu, 21 Mar 2019 21:53:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 222A56B0007; Thu, 21 Mar 2019 21:53:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D05F26B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 21:52:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m17so704177pgk.3
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 18:52:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=40NWW8wLR1ruw4bwc6cScxdYZkXDr2Pxr9BdklVtdM4=;
        b=NlPJXoEb2zrnYMm1Va1GJVvAF6UdDFGuMrhNlAcJzFnfPGjgOczBJg6xhFel5vnt0A
         paIopvUbvuAhuahNCqSE39aJcz0VPjStL5QISQuM4KCHsZPTjncBZOQ2dWRQzkvJVV2d
         MsKt2T+CawYwNcNuFJRa68lLQSnNB36XhsUr/S4d7AX5kazPXgheK6QN9SOAnJ2RhXda
         GS+zx4UmrzpK5VDA2084R0Av3tIT5tV4lWcCuquFCoc9ZJXZz+ZGn/FVkF2bmZYBau1N
         Ms4I76wvr5KN9+ZT5rJXX90BheUehXYj061nqBnzwbgnpFUQIbXDY9qYxVxdkDsWVdrJ
         ZEzA==
X-Gm-Message-State: APjAAAWNxf0jJ38dP9RyKlu7PE8SGOwMr0nG0mNIl91e5khNQejnwh3N
	FeQHvIKKniy3jkUPYqsaDTE2HSoNxUOeHKDGl6X8F/WL/r/DC/bNf8uadO3yFEDQaKlmDuQKwby
	GtlD6IeIbYDN/d2u1Z+FAFhEZpK5THrO5vYcZ3FvuVK/RXrpsiPM/R6hi/Fax3atGrQ==
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr6238471pgr.411.1553219579337;
        Thu, 21 Mar 2019 18:52:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZihAGOkz5iCyyESFSEbU3UgvuM+woupXUGVFdwHIjfYy+FcJUAeYuuFK358CVR6YG/Eho
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr6238361pgr.411.1553219577545;
        Thu, 21 Mar 2019 18:52:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553219577; cv=none;
        d=google.com; s=arc-20160816;
        b=oUKNmxUPvQSnF6XGZdaHbOUX5ddyXG6BM517A6f9DKy8hKrsoGvdDJl6+8JCRjGsHE
         24sk0NfSbKHUvXsEwP21ffOT2VMLXkTv6azzhwjVIh5TC9Xw2/Yd6xNNPnyzyWA1ZvSb
         vgP/InumRNb/bIsL7OPfiDPGxTWWG73pwl5Q3bYRbZkan89T4D1ZgXbfmlLOVlQim49E
         qm7Vlqgf4hjP5Za2O7uR4gw65pfySWJ8JR1LVg7+OeHGkhWm/8W2J9eBU1LVuSXHf18O
         lUhW/jKv3tKzvBSPyxYQz20Xv99nN5nwI3D9g5ARsFJYsJSFT9Gbr6DMBR1kQvXwhjld
         tBng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=40NWW8wLR1ruw4bwc6cScxdYZkXDr2Pxr9BdklVtdM4=;
        b=wjgNchCSiUBzLSH40amZTW27PaeTAHHDnB/nYpFZxARdI+tcJw7YvZyqkkieXa5XBB
         1TF2prQMtfsepBef5Bn4dncdiaP/Qg5FGL3wcdiVuHKk6VdRf0sUcl7KDXjLyteL2REW
         3DfqO4Y1okMTFZJ9hxTgY7vmFYJmJDAbQFgPu8iYd3apU32QLKV4opzpK8Y/plnrgX7h
         tD6xqfK60UKJvx/Tr2IlQZtNKOl5ejJH5mLjuK4Wl9TAycxobvCbG5hbX5m9zEiTk2rl
         3skZ643QK5Pa1OIS9kNUDA7uaOXygMxvcuLOLOpL8snTW8ySSsrVNIKzqL4h0xYAcb4z
         fq7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JUvjG7dL;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bj7si2393649plb.408.2019.03.21.18.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Mar 2019 18:52:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JUvjG7dL;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=40NWW8wLR1ruw4bwc6cScxdYZkXDr2Pxr9BdklVtdM4=; b=JUvjG7dL+Zhx0nDTZf6CzESCk
	+hW90ni/TULy5MPA+m+P9k1P0lD1verHqsYtRH64fANL3gDMoggs0scCQ9XL+RyWZ9s1obr+PzENn
	qA6Nwqtw3zbfAh+4X1UOQQZh+2XiQhbjDDNesOkrwx0ar8AmidhxBEOpEIIntbmxAFE9RDInqxVal
	u+U9tQOOWgAizuJmzF2JsVlLzOAmY+kB0McsfWT7AgjGTbf2Udwzoq1sbbM49hO0ywY4FVwoZ2c0f
	MKPMwdJSLSqttRzikdI4hiJqUD+Tbi7SMwrjYQ8/wc8kPZWxsNyy0ZwH3ZkDDoUB/+ME2jiEVf73Z
	eis8n0MkQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h79Lt-0002cG-4i; Fri, 22 Mar 2019 01:52:09 +0000
Date: Thu, 21 Mar 2019 18:52:08 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
Message-ID: <20190322015208.GD19508@bombadil.infradead.org>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-3-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190321214512.11524-3-longman@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 05:45:10PM -0400, Waiman Long wrote:
> It was found that if a process had many pending signals (e.g. millions),
> the act of exiting that process might cause its parent to have a hard
> lockup especially on a debug kernel with features like KASAN enabled.
> It was because the flush_sigqueue() was called in release_task() with
> tasklist_lock held and irq disabled.

This rather apocalyptic language is a bit uncalled for.  I appreciate the
warning is scary, but all that's really happening is that the debug code
is taking too long to execute.

> To avoid this dire condition and reduce lock hold time of tasklist_lock,
> flush_sigqueue() is modified to pass in a freeing queue pointer so that
> the actual freeing of memory objects can be deferred until after the
> tasklist_lock is released and irq re-enabled.

I think this is a really bad solution.  It looks kind of generic,
but isn't.  It's terribly inefficient, and all it's really doing is
deferring the debugging code until we've re-enabled interrupts.

We'd be much better off just having a list_head in the caller
and list_splice() the queue->list onto that caller.  Then call
__sigqueue_free() for each signal on the queue.

