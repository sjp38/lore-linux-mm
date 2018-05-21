Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30C576B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 01:53:58 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l8-v6so13270171qtb.11
        for <linux-mm@kvack.org>; Sun, 20 May 2018 22:53:58 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id i6-v6si1755784qvj.65.2018.05.20.22.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 22:53:57 -0700 (PDT)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 76C8F22006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 01:53:56 -0400 (EDT)
Message-Id: <1526882035.2651626.1378964120.19800D70@webmail.messagingengine.com>
From: Benjamin Peterson <bp@benjamin.pe>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
Date: Sun, 20 May 2018 22:53:55 -0700
Subject: balance_dirty_pages ratelimiting
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

The comment for balance_dirty_pages_ratelimited explains rate limiting is necessary because "On really big machines, get_writeback_state is expensive". This comment is stale, since get_writeback_state has not existed for more than 10 years. I gather, however, that its expense arose from aggregating vmstats over all cpus. These days, global vmstats are simply a memory load. Is there a modern reason for rate limiting balance_dirty_pages?

Thanks,
Benjamin
