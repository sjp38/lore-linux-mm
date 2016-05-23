Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70FA36B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 18:13:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so385430899pfy.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 15:13:45 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id x10si43449092pas.64.2016.05.23.15.13.44
        for <linux-mm@kvack.org>;
        Mon, 23 May 2016 15:13:44 -0700 (PDT)
Date: Mon, 23 May 2016 15:13:43 -0700 (PDT)
Message-Id: <20160523.151343.1506737172909544113.davem@davemloft.net>
Subject: Re: [PATCH 8/8] af_unix: charge buffers to kmemcg
From: David Miller <davem@davemloft.net>
In-Reply-To: <ba7e91e4f7aaea4e4d3b4ce60bf8bb2a3eceba0a.1463997354.git.vdavydov@virtuozzo.com>
References: <cover.1463997354.git.vdavydov@virtuozzo.com>
	<ba7e91e4f7aaea4e4d3b4ce60bf8bb2a3eceba0a.1463997354.git.vdavydov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov@virtuozzo.com
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Networking changes should be CC:'d netdev@vger.kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
