Message-ID: <44DFCA28.7040808@google.com>
Date: Sun, 13 Aug 2006 17:56:08 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
References: <1155127040.12225.25.camel@twins> <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins> <44DD4E3A.4040000@redhat.com> <20060812084713.GA29523@2ka.mipt.ru> <1155374390.13508.15.camel@lappy> <20060812093706.GA13554@2ka.mipt.ru> <44DDE857.3080703@redhat.com> <20060812144921.GA25058@2ka.mipt.ru> <44DDEC1F.6010603@redhat.com> <20060812150842.GA5638@2ka.mipt.ru>
In-Reply-To: <20060812150842.GA5638@2ka.mipt.ru>
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Evgeniy Polyakov wrote:
> One must receive a packet to determine if that packet must be dropped
> until tricky hardware with header split capabilities or MMIO copying is
> used. Peter uses special pool to get data from when system is in OOM (at
> least in his latest patchset), so allocations are separated and thus
> network code is not affected by OOM condition, which allows to make
> forward progress.

Nice executive summary.  Crucial point: you want to say "in reclaim"
not "in OOM".

Yes, right from the beginning the patch set got its sk_buff memory
from a special pool when the system is in reclaim, however the exact
nature of the pool and how/where it is accounted has evolved... mostly
forward.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
