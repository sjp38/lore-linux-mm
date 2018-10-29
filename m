Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7066B04A7
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 16:47:01 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id n2-v6so1752922wrj.19
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 13:47:01 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id k4-v6si19837524wrh.191.2018.10.29.13.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 13:46:59 -0700 (PDT)
Message-ID: <1540846014.4434.10.camel@gmx.de>
Subject: Re: memcg oops:
 memcg_kmem_charge_memcg()->try_charge()->page_counter_try_charge()->BOOM
From: Mike Galbraith <efault@gmx.de>
Date: Mon, 29 Oct 2018 21:46:54 +0100
In-Reply-To: <20181029185412.GA15760@tower.DHCP.thefacebook.com>
References: <1540792855.22373.34.camel@gmx.de>
	 <20181029132035.GI32673@dhcp22.suse.cz> <1540830938.10478.4.camel@gmx.de>
	 <20181029185412.GA15760@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, 2018-10-29 at 18:54 +0000, Roman Gushchin wrote:
> 
> Hi Mike!
> 
> Thank you for the report!
> 
> Do you see it reliable every time you boot up the machine?

Yeah.

> How do you run kvm?

My VMs are full SW/data clones of my i7-4790/openSUSE <release> box.

>  Is there something special about your cgroup setup?

No, I generally have no use for cgroups.

> I've made several attempts to reproduce the issue, but haven't got anything
> so far. I've used your config, and played with different cgroups setups.

Ah, I have cgroup_disable=memory on the command line, which turns out
to be why your box doesn't explode, while mine does.

> Do you know where in the page_counter_try_charge() it fails?
> 
> Also, can you, please, check if the following patch mitigates the problem?

Yeah, that plugs it up.

	-Mike
