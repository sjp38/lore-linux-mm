Subject: Re: 2.5.59-mm5
References: <20030123195044.47c51d39.akpm@digeo.com>
	<946253340.1043406208@[192.168.100.5]>
	<20030124031632.7e28055f.akpm@digeo.com>
	<m3d6mmvlip.fsf@lexa.home.net>
	<20030124035017.6276002f.akpm@digeo.com>
	<m3lm1au51v.fsf@lexa.home.net>
	<20030124111249.227a40d6.akpm@digeo.com>
From: Alex Tomas <bzzz@tmi.comex.ru>
Date: 24 Jan 2003 22:58:13 +0300
In-Reply-To: <20030124111249.227a40d6.akpm@digeo.com>
Message-ID: <m34r7ys4kq.fsf@lexa.home.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alex Tomas <bzzz@tmi.comex.ru>, linux-kernel@alex.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> Andrew Morton (AM) writes:

 AM> We cannot free disk blocks until I/O against them has completed.
 AM> Otherwise the block could be reused for something else, then the
 AM> old IO will scribble on the new data.

 AM> What we _can_ do is to defer the waiting - only wait on the I/O
 AM> when someone reuses the disk blocks.  So there are actually
 AM> unused blocks with I/O in flight against them.

 AM> We do that for metadata (the wait happens in
 AM> unmap_underlying_metadata()) but for file data blocks there is no
 AM> mechanism in place to look them up

yeah! indeed. my stupid mistake ...




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
