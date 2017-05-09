Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDDDE2806E3
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:37:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y106so1049303wrb.14
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:37:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 38si333870wrm.255.2017.05.09.08.37.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 08:37:03 -0700 (PDT)
Date: Tue, 9 May 2017 17:37:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmalloc: fix vmalloc users tracking properly
Message-ID: <20170509153702.GR6481@dhcp22.suse.cz>
References: <20170509144108.31910-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509144108.31910-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tobias Klauser <tklauser@distanz.ch>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Sigh. I've apparently managed to screw up again. This should address the
nommu breakage reported by 0-day.
---
