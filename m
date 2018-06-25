Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0450E6B0269
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:07:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f6-v6so2352406eds.6
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 07:07:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8-v6si7896880edl.126.2018.06.25.07.07.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 07:07:55 -0700 (PDT)
Date: Mon, 25 Jun 2018 16:07:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: why do we still need bootmem allocator?
Message-ID: <20180625140754.GB29102@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I am wondering why do we still keep mm/bootmem.c when most architectures
already moved to nobootmem. Is there any fundamental reason why others
cannot or this is just a matter of work? Btw. what really needs to be
done? Btw. is there any documentation telling us what needs to be done
in that regards?
-- 
Michal Hocko
SUSE Labs
