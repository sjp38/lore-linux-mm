Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28F196B0007
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 15:15:53 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a40-v6so12230062pla.5
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:15:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q33-v6si26933377pgk.2.2018.10.31.12.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 12:15:52 -0700 (PDT)
Date: Wed, 31 Oct 2018 12:15:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory_hotplug: cond_resched in __remove_pages
Message-Id: <20181031121550.2f0cbd10a948880e534beaf7@linux-foundation.org>
In-Reply-To: <20181031125840.23982-1-mhocko@kernel.org>
References: <20181031125840.23982-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@gmail.com>, Johannes Thumshirn <jthumshirn@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 31 Oct 2018 13:58:40 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> We have received a bug report that unbinding a large pmem (>1TB)
> can result in a soft lockup:
> 
> ...
>
> It has been reported on an older (4.12) kernel but the current upstream
> code doesn't cond_resched in the hot remove code at all and the given
> range to remove might be really large. Fix the issue by calling cond_resched
> once per memory section.
> 

Worthy of a cc:stable, I suggest?
