Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36B606B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 04:19:42 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id b79so18278722wrd.19
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:19:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v21si3713678edb.428.2017.11.27.01.19.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 01:19:40 -0800 (PST)
Date: Mon, 27 Nov 2017 10:19:39 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Message-ID: <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Yafang Shao <laoar.shao@gmail.com>, akpm@linux-foundation.org, jack@suse.cz, linux-mm@kvack.org

Andrew,
could you simply send this to Linus. If we _really_ need something to
prevent misconfiguration, which I doubt to be honest, then it should be
thought through much better.
---
