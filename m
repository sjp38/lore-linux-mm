Subject: Re: 2.5.59-mm5
References: <20030123195044.47c51d39.akpm@digeo.com>
	<946253340.1043406208@[192.168.100.5]>
	<20030124031632.7e28055f.akpm@digeo.com>
From: Alex Tomas <bzzz@tmi.comex.ru>
Date: 24 Jan 2003 14:23:58 +0300
In-Reply-To: <20030124031632.7e28055f.akpm@digeo.com>
Message-ID: <m3d6mmvlip.fsf@lexa.home.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alex Bligh - linux-kernel <linux-kernel@alex.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> Andrew Morton (AM) writes:

 AM> But writes are completely different.  There is no dependency
 AM> between them and at any point in time we know where on-disk a lot
 AM> of writes will be placed.  We don't know that for reads, which is
 AM> why we need to twiddle thumbs until the application or filesystem
 AM> makes up its mind.


it's significant that application doesn't want to wait read completion
long and doesn't wait for write completion in most cases.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
