Message-ID: <3B7030B3.9F2E8E67@zip.com.au>
Date: Tue, 07 Aug 2001 11:17:23 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
References: <Pine.LNX.4.31.0108070920440.31117-100000@cesium.transmeta.com> <Pine.LNX.4.33.0108071245250.30280-100000@touchme.toronto.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ben LaHaise wrote:
> 
> On Tue, 7 Aug 2001, Linus Torvalds wrote:
> 
> > Try pre4.
> 
> It's similarly awful (what did you expect -- there are no meaningful
> changes between the two!).  io throughput to a 12 disk array is humming
> along at a whopping 40MB/s (can do 80) that's very spotty and jerky,
> mostly being driven by syncs.  vmscan gets delayed occasionally, and small
> interactive program loading varies from not to long (3s) to way too long
> (> 30s).

Ben, are you using software RAID?

The throughput problems which Mike Black has been seeing with
ext3 seem to be specific to an interaction with software RAID5
and possibly highmem.  I've never been able to reproduce them.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
