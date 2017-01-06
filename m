Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 821476B025E
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 07:16:44 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id n3so70237232wjy.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 04:16:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 73si2487369wmn.146.2017.01.06.04.16.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 04:16:43 -0800 (PST)
Date: Fri, 6 Jan 2017 13:16:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: weird allocation pattern in alloc_ila_locks
Message-ID: <20170106121642.GJ5556@dhcp22.suse.cz>
References: <20170106095115.GG5556@dhcp22.suse.cz>
 <20170106100433.GH5556@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106100433.GH5556@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Herbert <tom@herbertland.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

I was thinking about the rhashtable which was the source of the c&p and
it can be simplified as well.
---
