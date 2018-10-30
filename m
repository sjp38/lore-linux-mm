Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16A816B04B8
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 23:15:03 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t129-v6so9829803wmd.7
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 20:15:03 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.20])
        by mx.google.com with ESMTPS id v62-v6si11802101wmb.186.2018.10.29.20.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 20:15:01 -0700 (PDT)
Message-ID: <1540869294.4811.3.camel@gmx.de>
Subject: Re: memcg oops:
 memcg_kmem_charge_memcg()->try_charge()->page_counter_try_charge()->BOOM
From: Mike Galbraith <efault@gmx.de>
Date: Tue, 30 Oct 2018 04:14:54 +0100
In-Reply-To: <20181029214913.GB13325@tower.DHCP.thefacebook.com>
References: <1540792855.22373.34.camel@gmx.de>
	 <20181029132035.GI32673@dhcp22.suse.cz> <1540830938.10478.4.camel@gmx.de>
	 <20181029185412.GA15760@tower.DHCP.thefacebook.com>
	 <1540846014.4434.10.camel@gmx.de>
	 <20181029214913.GB13325@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, 2018-10-29 at 21:49 +0000, Roman Gushchin wrote:
> On Mon, Oct 29, 2018 at 09:46:54PM +0100, Mike Galbraith wrote:
> 
> > Ah, I have cgroup_disable=memory on the command line, which turns out
> > to be why your box doesn't explode, while mine does.
> 
> Yeah, here it is. I'll send the fix in few minutes. Please,
> test it on your setup. Your tested-by will be appreciated.

Yup, all-better-by:/me
