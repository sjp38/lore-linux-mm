Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96491C072B5
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 02:23:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 576102173C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 02:23:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rrMba+ZX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 576102173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E21966B0003; Tue, 21 May 2019 22:23:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAB536B0006; Tue, 21 May 2019 22:23:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C24996B0007; Tue, 21 May 2019 22:23:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87D586B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 22:23:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e6so696925pgl.1
        for <linux-mm@kvack.org>; Tue, 21 May 2019 19:23:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RGSA3MkMjl461FtxfCjfoorkrQGEUA618qbWHIRefn8=;
        b=Vfm+HkfuB1Y5cKfZcQ5BYvHEJqGYDCW485YH8gnUB2mJ38kJReFvtYqMhyjjlsfoTg
         CzdX2fV61ohV/PBQHi7CxIsVvaAWkaKZMElX/bI4LXFvDtOSJkMJTExoYgC7NXHLcs2T
         O+e3Sj7axr2JZjrEa7Tue3e9m3RcYmHWEuEzPiLNs3ayUM5KlnV0ANNhxCCZVsZW83f9
         HP+AaPnPDDa8mTb9doValXqG6yqd6GDR8cHhINESrkGRPexq2Dz/NJENIz5YhQgKN5wT
         zvEF8Qq4KAoEiamc9qjI6Dgmzy2nebvh2PwI4W9GI7cmVViM7uIJZszj5sQ/c2lEXFa4
         TmHA==
X-Gm-Message-State: APjAAAUAWClzCDol13r71o+Y8HLlegYjRXMxuXG2JNrYWRq6mxljJlff
	XUdanKkBEKXJNYhgzZzO2IUUCFt63BCm1a9Ect72JHd4rq5YNqjyICuBYKHQVGPgK7k/Zz57B6k
	Zf3SvgDxtGYneCgrH2rd8AaYwjoxSSKH4Y4HjVYzW//mNkOVxZt+lKF5JSBonmK0SlQ==
X-Received: by 2002:a17:902:2ae6:: with SMTP id j93mr64574464plb.130.1558491833211;
        Tue, 21 May 2019 19:23:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRK7aldwW1lxzP0/MVnVMW3ZRfERBamaco0fUECDEqVax0Cb+61GFeR2/G51BvdgxnbQjR
X-Received: by 2002:a17:902:2ae6:: with SMTP id j93mr64574391plb.130.1558491832450;
        Tue, 21 May 2019 19:23:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558491832; cv=none;
        d=google.com; s=arc-20160816;
        b=egvdn5Cs9in30GOrw0cCJ+7Xu89Dgl47lPEQZejPuUQUD6EPKvcytbKVBIZ2AZZN9+
         CKbI9F47W2K2ks7Db6torOahtEjbyZFlhKUiNTGb3ODt+nowu4wVDBBER6KPXoky5sA0
         G+J7fRO5rm//pcVt1oyG3oKMeFW7+xCAvgnAsL5mP4ZUZwfOQFvEc1CSaDXTOaqMLhtY
         PSbIyM6RffiUQBEID+KqJTRaQM4U5uJlX8fqP8GU+jq2x19R7THKDD2mh3Mr3ohCSRDg
         96UPWnzKhNl9N0rteGvFyGx2YXnffYOvweIB0EkMtyA8FWbsgM5O8ciTdv6/bO7n98/R
         9GGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RGSA3MkMjl461FtxfCjfoorkrQGEUA618qbWHIRefn8=;
        b=gtZH+SaOtk+xM46gEf4gZx6vV0vZX7L7uvfijk75gI+JZKIv6wFKOUFMj+Rt6kxPyR
         0IM+XJpb8zuXqhH7/7THkox/ZWZb1AQyrOYjUBUc/UB3Iznky+1H7Cp6UqKVPz3S2Stc
         ZzUqXfCcDcfDat9tRtAmPPJbfj/11ZK77TEGydAr1/sqb+NKrz794qSaocMD0RbpHOzE
         0mJzRAVzvJGbrzUz/HGZLauHkgTW94wC0gwtNjUdZy/UndwVt72sYAqgclGTvocVjeyV
         xB1fhDoBE3xobJriF+p/X83JEq0luYpaAPI5xU3UD6WZKRSBOQK3/JE2BO6l/CFJ+taU
         t3UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rrMba+ZX;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y2si22919548plp.79.2019.05.21.19.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 19:23:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rrMba+ZX;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B50F72173C;
	Wed, 22 May 2019 02:23:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558491832;
	bh=wUT9Oh+IJNtkbs2q1QgrEx8t9Q4hOJE0j84LxGl06Ug=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=rrMba+ZX8lAWROnAkoY5D87S9fOHTRdkoZESFNef+egifs+9lW5INd3V34LCpOvOW
	 ep7TPyh1yBfU7lTlu2c/pnv0E+itIOFlpZ0CBGnpLSdfWnHistSsaGwGjpZ44icvk7
	 UFRqgijB26uTYluj1BTcuo9Hh9ACLE+qIkeUJN3I=
Date: Tue, 21 May 2019 19:23:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, mm-commits@vger.kernel.org,
 tj@kernel.org, guro@fb.com, dennis@kernel.org, chris@chrisdown.name,
 cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
Message-Id: <20190521192351.4d3fd16c6f0e6a0b088779a6@linux-foundation.org>
In-Reply-To: <20190518013348.GA6655@cmpxchg.org>
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
	<20190213124729.GI4525@dhcp22.suse.cz>
	<20190516175655.GA25818@cmpxchg.org>
	<20190516180932.GA13208@dhcp22.suse.cz>
	<20190516193943.GA26439@cmpxchg.org>
	<20190517123310.GI6836@dhcp22.suse.cz>
	<20190518013348.GA6655@cmpxchg.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 May 2019 21:33:48 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> - Adoption data suggests that cgroup2 isn't really used yet. RHEL8 was
>   just released with cgroup1 per default. Fedora is currently debating
>   a switch. None of the other distros default to cgroup2. There is an
>   article on the lwn frontpage *right now* about Docker planning on
>   switching to cgroup2 in the near future. Kubernetes is on
>   cgroup1. Android is on cgroup1. Shakeel agrees that Facebook is
>   probably the only serious user of cgroup2 right now. The cloud and
>   all mainstream container software is still on cgroup1.

I'm thinking we need a cc:stable so these forthcoming distros are more
likely to pick up the new behaviour?

Generally, your arguments sound good to me - I don't see evidence that
anyone is using cgroup2 in a manner which is serious enough to be
seriously affected by this change.

