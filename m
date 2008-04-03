From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] SLQB: YASA
Date: Thu, 03 Apr 2008 17:17:39 +0900
Message-ID: <20080403171626.0283.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <84144f020804030045p44456894lfc006dcdeab6f67c@mail.gmail.com> <20080403075725.GA7514@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760623AbYDCIRn@vger.kernel.org>
In-Reply-To: <20080403075725.GA7514@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

Hi 

> > Why is this not a patch set against SLUB?
> 
> It's a completely different design of the core allocator algorithms
> really.
> 
> It probably looks quite similar because I started with slub.c, but
> really is just the peripheral supporting code and structure. I'm never
> intending to try to go through the pain of incrementally changing SLUB
> into SLQB. If SLQB is found to be a good idea, then it could maybe get
> merged.

Do you have performance mesurement result?
I hope see it if possible.

Thanks! :)
