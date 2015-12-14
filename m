Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 100996B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:52:59 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p66so60475288wmp.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:52:59 -0800 (PST)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id m123si8537587wmb.50.2015.12.14.11.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 11:52:58 -0800 (PST)
Date: Mon, 14 Dec 2015 19:52:40 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151214195240.4372e2c9@lxorguk.ukuu.org.uk>
In-Reply-To: <20151214194258.GH28521@esperanza>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
	<265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
	<20151214153037.GB4339@dhcp22.suse.cz>
	<20151214194258.GH28521@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Anyway, if you don't trust a container you'd better set the hard memory
> limit so that it can't hurt others no matter what it runs and how it
> tweaks its sub-tree knobs.

If you don't trust it put it in a VM. If it's got access to GEM graphics
ioctls/nodes or some other kernel interfaces then it can blow up the
kernel without trying hard unless its constrained within a VM. VMs can
be extremely light weight if you avoid KVM emulating an entire PC.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
