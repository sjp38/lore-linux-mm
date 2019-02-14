Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BCBBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:30:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A4F621916
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:30:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A4F621916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2F48E0002; Thu, 14 Feb 2019 15:30:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9F5E8E0001; Thu, 14 Feb 2019 15:30:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB7128E0002; Thu, 14 Feb 2019 15:30:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0A18E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:30:09 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d3so5090599pgv.23
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:30:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=014kmWKdZnQ5ek9CQiz5h17iGhQ1vzM21YymOgXgDIs=;
        b=jhn0vmaWV7XmrsuTqV+j7NTCfwsYTozq9wPdChMFiPOpMPKcOwQ/kmKacjvLjeQ6Ud
         NVKjnOrMgkdOx81HNhbEiHQbgFhu9vvpiSJL1/oOhAlEq5s1W/c0n6vrRsoQWEQu4X12
         VD8AB1yDFcAMc+svT/yRu+UFVyZW1iGFNV8cSBy+u+Aa3pAChRa40ZDgM87EF25XuRG6
         acVARBUJLXevro72CxEPiR4R6IAS9SwyO2/c9hMsd02OpYuJV05eIOAJsizj/LOOuv6j
         Mv/oPatg/mqNzcJQwUdpkjEbogyrjSEuWgntLZ+E7qIY19mljgpWwlVlws8zWncmkF3F
         AfiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYBNp2v8BYqTPcdFv2eMc7RWOdkj92qXRX3wae8SF8OWHmg7LU1
	EgNCm6MGbGxyldXd749Anc5CD78j7pb1IY2OKBtSTA62FU+2nYnN0Gx6+QHu+4B/YwdqLTuH5+D
	9OojlKJydFKHCBkdPpEYK4aitDETGG5rX440NzYPXn76ZLNk3FNhC2ZefuTZwrie14w==
X-Received: by 2002:a17:902:8641:: with SMTP id y1mr6132904plt.159.1550176209116;
        Thu, 14 Feb 2019 12:30:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZHn69uFssr3bOx6aQHsArG2WmTnXqmVMSireISH7uF/2GFALywwtIgOqO2dU9yLjsBkSIf
X-Received: by 2002:a17:902:8641:: with SMTP id y1mr6132856plt.159.1550176208418;
        Thu, 14 Feb 2019 12:30:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550176208; cv=none;
        d=google.com; s=arc-20160816;
        b=Z/yzezKMN3DEiZgWgl1qE9EO0DXtup86eP7JsrXXfsxIOKp8h6WKBaBFMMrGDsquoF
         OxnwZi38zcjcndmh/ZrJA3gFkcPet6alhRUgDeydjcJFW0qQXverkUIsuNS+Uyw1iO0t
         WPHF7GoWTrkXXXbMA5l5MXi7EQUse8T20azC47e3NlSDLuq/8ZEbtVmi8+QBLAxP85e0
         BneNpnw+1AgR0WrbIjl9LK06srZ/slnDHfN9z6byJL/AjeucdWkCWeBA0fikwfSV+0ko
         Z6ug5bFgxVdCadL3i9XfFv3sdRwRPZ/g6Zus3ccPrsiAb49TQXJyQZwtKmqPASb/P/QY
         BhBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=014kmWKdZnQ5ek9CQiz5h17iGhQ1vzM21YymOgXgDIs=;
        b=TzVOJAnWyNybh/bu2rDMls7o6IUtGC7fUZ0cNA8ny4wz4au0ZvlUtKYtmyR2ghZHsk
         FkQquNJlQTW09qikqfa82BNnE4QE7tp6IUo5UpEPrPx0Tk2tRPlTYqTj6wFZGNoJmhZy
         mOebqVGpkM5eUQS4cEQa1lm0yHDsv4w6Qd1fAtC93gs6h3Xr1x0Mmv3IkzXC4rdTX9jw
         PIeebNLHKFaLbS7h8ZarQ41l8rhzCOMNneGxV5CX4AiWcuVtQNEXC5QN9K0XIKmEMujX
         7fagQu/6cIxCDLJynQxSjYanW8ZEQR5izNkfX4q7aLGxv5gFLvKIgNLUqzGStn2LdIuB
         SRWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r17si3290839pgr.331.2019.02.14.12.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 12:30:08 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9C690AD1;
	Thu, 14 Feb 2019 20:30:07 +0000 (UTC)
Date: Thu, 14 Feb 2019 12:30:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
 "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Minchan Kim
 <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen
 <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>,
 =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Andrea Arcangeli
 <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel
 <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang
 <dave.jiang@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrea
 Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some
 swap operations
Message-Id: <20190214123002.b921b680fea07bf5f798df79@linux-foundation.org>
In-Reply-To: <20190214143318.GJ4525@dhcp22.suse.cz>
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190214143318.GJ4525@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2019 15:33:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > Because swapoff() is very rare code path, to make the normal path runs as
> > fast as possible, disabling preemption + stop_machine() instead of
> > reference count is used to implement get/put_swap_device().  From
> > get_swap_device() to put_swap_device(), the preemption is disabled, so
> > stop_machine() in swapoff() will wait until put_swap_device() is called.
> > 
> > In addition to swap_map, cluster_info, etc.  data structure in the struct
> > swap_info_struct, the swap cache radix tree will be freed after swapoff,
> > so this patch fixes the race between swap cache looking up and swapoff
> > too.
> > 
> > Races between some other swap cache usages protected via disabling
> > preemption and swapoff are fixed too via calling stop_machine() between
> > clearing PageSwapCache() and freeing swap cache data structure.
> > 
> > Alternative implementation could be replacing disable preemption with
> > rcu_read_lock_sched and stop_machine() with synchronize_sched().
> 
> using stop_machine is generally discouraged. It is a gross
> synchronization.

This was discussed to death and I think the changelog explains the
conclusions adequately.  swapoff is super-rare so a stop_machine() in
that path is appropriate if its use permits more efficiency in the
regular swap code paths.  

> Besides that, since when do we have this problem?

What problem??

