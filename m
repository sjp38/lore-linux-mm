Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E7A9F6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 16:36:14 -0500 (EST)
Received: by wivr20 with SMTP id r20so18221903wiv.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 13:36:14 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id ey12si20578143wid.77.2015.03.02.13.36.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 13:36:13 -0800 (PST)
Received: by wghk14 with SMTP id k14so36248509wgh.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 13:36:12 -0800 (PST)
Date: Mon, 2 Mar 2015 22:36:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] sparc: clarify __GFP_NOFAIL allocation
Message-ID: <20150302213610.GA31974@dhcp22.suse.cz>
References: <1425304483-7987-4-git-send-email-mhocko@suse.cz>
 <20150302.150405.2072800922470200977.davem@davemloft.net>
 <20150302203304.GA20513@dhcp22.suse.cz>
 <20150302.154424.30182050492471222.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302.154424.30182050492471222.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, david@fromorbit.com, tytso@mit.edu, mgorman@suse.de, penguin-kernel@I-love.SAKURA.ne.jp, sparclinux@vger.kernel.org, vipul@chelsio.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 02-03-15 15:44:24, David S. Miller wrote:
[...]
> > OK, thanks for the clarification. This wasn't clear from the commit
> > which has introduced this code. I will drop this patch. Would you
> > accept something like the following instead?
> 
> Sure.

Thanks!

---
