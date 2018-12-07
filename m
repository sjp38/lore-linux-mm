Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDE766B7E3F
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 23:29:18 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e29so1401163ede.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 20:29:18 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i20-v6sor816768ejy.21.2018.12.06.20.29.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 20:29:17 -0800 (PST)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id x10sm678899edb.58.2018.12.06.20.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 20:29:16 -0800 (PST)
Date: Fri, 7 Dec 2018 04:29:15 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [Question] Why we always pass NULL to drain_local_pages() in
 drain_local_pages_wq()?
Message-ID: <20181207042915.k6stltnobn466jmt@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Just took a look into the code of __offline_pages().

Even we may get the zone information, but it is never told to the WQ.
This will leads to the WQ drain pcp for all zones, even some of them are
not what we want to.

Curious about the background behind this.

-- 
Wei Yang
Help you, Help me
