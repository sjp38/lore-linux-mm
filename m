Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E7AE6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 08:35:52 -0400 (EDT)
Date: Mon, 15 Jun 2009 08:36:58 -0400
From: Bart Trojanowski <bart@jukie.net>
Subject: Re: [v2.6.30 nfs+fscache] kswapd1: blocked for more than 120
	seconds
Message-ID: <20090615123658.GC4721@jukie.net>
References: <20090613182721.GA24072@jukie.net> <25357.1245068384@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25357.1245068384@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Howells <dhowells@redhat.com> [090615 08:20]:
> Bart Trojanowski <bart@jukie.net> wrote:
> 
> >   - my cachefilesd uses xfs on MD raid0 volume over two SATA disks
> 
> Is it possible for you try it with ext3 instead of XFS?  I'd be interested to
> know if this is something XFS specific.

Sure, I'll create a new lvm volume with ext3 on it and give it a try.
Can I just shutdown cachefilesd, relocate the cahce, and restart the
daemon without remounting the nfs volumes?

-Bart

-- 
				WebSig: http://www.jukie.net/~bart/sig/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
