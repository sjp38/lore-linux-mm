Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D5A8C6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 08:19:23 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090613182721.GA24072@jukie.net>
References: <20090613182721.GA24072@jukie.net>
Subject: Re: [v2.6.30 nfs+fscache] kswapd1: blocked for more than 120 seconds
Date: Mon, 15 Jun 2009 13:19:44 +0100
Message-ID: <25357.1245068384@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Bart Trojanowski <bart@jukie.net>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bart Trojanowski <bart@jukie.net> wrote:

>   - my cachefilesd uses xfs on MD raid0 volume over two SATA disks

Is it possible for you try it with ext3 instead of XFS?  I'd be interested to
know if this is something XFS specific.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
