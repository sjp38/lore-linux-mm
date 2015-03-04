Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBCD6B0070
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 16:21:29 -0500 (EST)
Received: by padet14 with SMTP id et14so40121211pad.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 13:21:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ku8si933177pab.103.2015.03.04.13.21.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 13:21:28 -0800 (PST)
Date: Wed, 4 Mar 2015 13:21:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: make CONFIG_MEMCG depend on CONFIG_MMU
Message-Id: <20150304132126.90dad77e36b21016b5a411a4@linux-foundation.org>
In-Reply-To: <20150304211301.GA22626@phnom.home.cmpxchg.org>
References: <1425492428-27562-1-git-send-email-mhocko@suse.cz>
	<20150304190635.GC21350@phnom.home.cmpxchg.org>
	<20150304192836.GA952@dhcp22.suse.cz>
	<20150304211301.GA22626@phnom.home.cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Chen Gang <762976180@qq.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>

On Wed, 4 Mar 2015 16:13:01 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> I don't even care about NOMMU, this is just wrong on principle.

Agree.  And I do care about nommu ;)

If some nommu person wants to start using memcg and manages to get it
doing something useful then good for them - we end up with a better
kernel.  We shouldn't go and rule this out without having even tried it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
