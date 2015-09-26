Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC2C6B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 04:04:12 -0400 (EDT)
Received: by lacrr8 with SMTP id rr8so39873321lac.2
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 01:04:11 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id yg1si1621712lab.57.2015.09.26.01.04.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 01:04:10 -0700 (PDT)
Received: by lacdq2 with SMTP id dq2so63902497lac.1
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 01:04:10 -0700 (PDT)
Date: Sat, 26 Sep 2015 10:04:01 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv2 0/3] align zpool/zbud/zsmalloc on the api
Message-Id: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ddstreet@ieee.org, akpm@linux-foundation.org, Seth Jennings <sjennings@variantweb.net>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Here comes the second iteration over zpool/zbud/zsmalloc API alignment. 
This time I divide it into three patches: for zpool, for zbud and for zsmalloc :)
Patches are non-intrusive and do not change any existing functionality. They only
add up stuff for the alignment purposes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
