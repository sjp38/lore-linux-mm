Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 904C56B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 16:56:44 -0500 (EST)
Received: by pfu207 with SMTP id 207so18403524pfu.2
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 13:56:44 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id mi6si7645605pab.95.2015.12.08.13.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 13:56:43 -0800 (PST)
Received: by pacej9 with SMTP id ej9so18309907pac.2
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 13:56:43 -0800 (PST)
Date: Tue, 8 Dec 2015 13:56:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: page_alloc: fix variable type in zonelist type
 iteration
In-Reply-To: <1449583412-22740-1-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1512081356290.29940@chino.kir.corp.google.com>
References: <1449583412-22740-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-616683805-1449611802=:29940"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-616683805-1449611802=:29940
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 8 Dec 2015, Johannes Weiner wrote:

> /home/hannes/src/linux/linux/mm/page_alloc.c: In function a??build_zonelistsa??:
> /home/hannes/src/linux/linux/mm/page_alloc.c:4171:16: warning: comparison between a??enum zone_typea?? and a??enum <anonymous>a?? [-Wenum-compare]
>   for (i = 0; i < MAX_ZONELISTS; i++) {
>                 ^
> 
> MAX_ZONELISTS has never been of enum zone_type, probably gcc only
> recently started including -Wenum-compare in -Wall.
> 
> Make i a simple int.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I think this is already handled by 
http://marc.info/?l=linux-kernel&m=144901185732632.
--397176738-616683805-1449611802=:29940--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
