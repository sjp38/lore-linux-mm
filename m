Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id B586D6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 20:16:45 -0400 (EDT)
Received: by iebrs15 with SMTP id rs15so143048703ieb.3
        for <linux-mm@kvack.org>; Mon, 04 May 2015 17:16:45 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id mn19si11757302icb.96.2015.05.04.17.16.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 17:16:45 -0700 (PDT)
Received: by ieczm2 with SMTP id zm2so418964iec.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 17:16:45 -0700 (PDT)
Message-ID: <1430785003.27254.20.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 May 2015 17:16:43 -0700
In-Reply-To: <20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
	 <20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, akpm@linux-foundation.org, davem@davemloft.net

On Mon, 2015-05-04 at 16:14 -0700, Alexander Duyck wrote:
> This change adds a function called skb_free_frag which is meant to
> compliment the function __alloc_page_frag.  The general idea is to enable a
> more lightweight version of page freeing since we don't actually need all
> the overhead of a put_page, and we don't quite fit the model of __free_pages.

Could you describe what are the things that put_page() handle that we
don't need for skb frags ?

It looks the change could benefit to other users (outside of networking)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
