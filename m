Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C0E0E6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 07:05:42 -0400 (EDT)
Date: Tue, 23 Jun 2009 04:05:51 -0700 (PDT)
Message-Id: <20090623.040551.37741458.davem@davemloft.net>
Subject: Re: [PATCH 3/3] net-dccp: Suppress warning about large allocations
 from DCCP
From: David Miller <davem@davemloft.net>
In-Reply-To: <4A40B69A.2020703@gmail.com>
References: <20090623023936.GA2721@ghostprotocols.net>
	<20090622.211927.245716932.davem@davemloft.net>
	<4A40B69A.2020703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: eric.dumazet@gmail.com
Cc: acme@redhat.com, mel@csn.ul.ie, akpm@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, htd@fancy-poultry.org
List-ID: <linux-mm.kvack.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Jun 2009 13:03:54 +0200

> But it has some bootmem references, it might need more work than
> just exporting it.

In that case we should probably just apply the original patch
for now, and leave this cleanup as a future change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
