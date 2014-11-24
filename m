Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5D26B0070
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 16:35:04 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id r2so5756279igi.5
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:35:04 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id c5si47904igo.4.2014.11.24.13.35.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 13:35:03 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id h15so3904471igd.14
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:35:03 -0800 (PST)
Date: Mon, 24 Nov 2014 13:35:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, gfp: escalatedly define GFP_HIGHUSER and
 GFP_HIGHUSER_MOVABLE
In-Reply-To: <20141124190127.GA5027@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.10.1411241334490.21237@chino.kir.corp.google.com>
References: <1416847427-2550-1-git-send-email-nasa4836@gmail.com> <20141124190127.GA5027@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jianyu Zhan <nasa4836@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, sasha.levin@oracle.com, n-horiguchi@ah.jp.nec.com, andriy.shevchenko@linux.intel.com, hannes@cmpxchg.org, vdavydov@parallels.com, fabf@skynet.be, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jianyu Zhan <jianyu.zhan@emc.com>

On Mon, 24 Nov 2014, Kirill A. Shutemov wrote:

> But I would prefer to have GPF_HIGHUSER movable by default and
> GFP_HIGHUSER_UNMOVABLE to opt out.
> 

Sounds like a separate patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
