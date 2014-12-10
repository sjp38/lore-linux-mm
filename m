Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id E68E26B006E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:17:13 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hn15so6708743igb.7
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:17:13 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id l5si1021920igv.17.2014.12.10.08.17.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:17:12 -0800 (PST)
Date: Wed, 10 Dec 2014 10:17:10 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Faster than SLAB caching of SKBs with qmempool
 (backed by alf_queue)
In-Reply-To: <20141210163321.0e4e4fd2@redhat.com>
Message-ID: <alpine.DEB.2.11.1412101016400.4657@gentwo.org>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20> <20141210141332.31779.56391.stgit@dragon> <alpine.DEB.2.11.1412100917020.4047@gentwo.org> <20141210163321.0e4e4fd2@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed, 10 Dec 2014, Jesper Dangaard Brouer wrote:

> That is very strange! I did notice that it was somehow delayed in
> showing up on gmane.org (http://thread.gmane.org/gmane.linux.network/342347/focus=126148)
> and didn't show up on netdev either...

It finally got through.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
