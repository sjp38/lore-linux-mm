Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFB9831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 05:29:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g143so24593185wme.13
        for <linux-mm@kvack.org>; Mon, 22 May 2017 02:29:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7si10450536wmv.91.2017.05.22.02.29.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 02:29:15 -0700 (PDT)
Date: Mon, 22 May 2017 11:29:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 1/1] mm: Adaptive hash table scaling
Message-ID: <20170522092910.GD8509@dhcp22.suse.cz>
References: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
 <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat 20-05-17 13:06:53, Pavel Tatashin wrote:
[...]
>  /*
> + * Adaptive scale is meant to reduce sizes of hash tables on large memory
> + * machines. As memory size is increased the scale is also increased but at
> + * slower pace.  Starting from ADAPT_SCALE_BASE (64G), every time memory
> + * quadruples the scale is increased by one, which means the size of hash table
> + * only doubles, instead of quadrupling as well.
> + */
> +#define ADAPT_SCALE_BASE	(64ull << 30)

I have only noticed this email today because my incoming emails stopped
syncing since Friday. But this is _definitely_ not the right approachh.
64G for 32b systems is _way_ off. We have only ~1G for the kernel. I've
already proposed scaling up to 32M for 32b systems and Andi seems to be
suggesting the same. So can we fold or apply the following instead?
---
