Date: Wed, 12 Apr 2000 12:02:44 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: zap_page_range(): TLB flush race
Message-ID: <20000412120244.G24128@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0004111824090.19969-100000@maclaurin.suse.de> <38F364B3.5A4A45D9@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <38F364B3.5A4A45D9@colorfullife.com>; from Manfred Spraul on Tue, Apr 11, 2000 at 07:45:23PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, alan@lxorguk.ukuu.org.uk, kanoj@google.engr.sgi.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Manfred Spraul wrote:
> Can we ignore the munmap+access case?
> I'd say that if 2 threads race with munmap+access, then the behaviour is
> undefined.
> Tlb flushes are expensive, I'd like to avoid the second tlb flush as in
> Kanoj's patch.

No, you can't ignore it.  A variation called mprotect+access is used by
garbage collection systems that expect to receive SEGVs when access is
to a protected region.

At very least, you'd have to document the race very clearly, and provide
a workaround.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
