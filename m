Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 741A86B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 05:43:18 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p77so9755136wrb.10
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 02:43:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u13si10183414wrg.380.2017.08.28.02.43.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 02:43:17 -0700 (PDT)
Date: Mon, 28 Aug 2017 11:43:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: timeout for memory offline
Message-ID: <20170828094316.GF17097@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Kamezawa,
I've been wondering why do we have a hardcoded 120s timeout for
offline_pages. This goes all the way down to when the offlining
has been implemented. I am asking because I have seen many cases
where memory offline fails just because of the timeout on a large
machines under heavy memory load during offline operation. So I
am really wondering whether we should make the timeout configurable or
just remove it altogether. I would be more inclined for the later
but there might have been an explicit reason for the timeout which is
not clear to me. Could you clarify?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
