Date: Tue, 15 Aug 2000 19:46:35 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Syncing the page cache, take 2
Message-ID: <20000815194635.H12218@redhat.com>
References: <news2mail-3999000E.4BED1557@innominate.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <news2mail-3999000E.4BED1557@innominate.de>; from news-innominate.list.linux.mm@innominate.de on Tue, Aug 15, 2000 at 10:32:14AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <daniel.phillips@innominate.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Aug 15, 2000 at 10:32:14AM +0200, Daniel Phillips wrote:
> 
> This is really a VFS problem not a mm problem per se, but since the two have
> become so closely intertwined I'm bringing it up here.
> 
> There seems to be something missing in the current VFS (please correct me if I'm
> wrong): the sync code totally ignores the page cache, so when you do a sync
> you're only syncing the buffer cache and not file data that may have been mapped
> into the page cache by file_write or file_mmap.

Correct.  We have plans to change this in 2.5, basically by removing
the VM's privileged knowledge about the buffer cache and making the
buffer operations (write-back, unmap etc.) into special cases of
generic address-space operations.  For 2.4, it's really to late to do
anything about this.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
