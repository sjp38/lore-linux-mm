From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] SLQB: YASA
Date: Thu, 3 Apr 2008 09:57:25 +0200
Message-ID: <20080403075725.GA7514@wotan.suse.de>
References: <20080403072550.GC25932@wotan.suse.de> <84144f020804030045p44456894lfc006dcdeab6f67c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762168AbYDCH5m@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <84144f020804030045p44456894lfc006dcdeab6f67c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

On Thu, Apr 03, 2008 at 10:45:44AM +0300, Pekka Enberg wrote:
> Hi Nick,
> 
> On Thu, Apr 3, 2008 at 10:25 AM, Nick Piggin <npiggin@suse.de> wrote:
> >  I'm not quite sure what to do with this. If anybody could test or comment,
> >  I guess that would be a good start :)
> 
> Why is this not a patch set against SLUB?

It's a completely different design of the core allocator algorithms
really.

It probably looks quite similar because I started with slub.c, but
really is just the peripheral supporting code and structure. I'm never
intending to try to go through the pain of incrementally changing SLUB
into SLQB. If SLQB is found to be a good idea, then it could maybe get
merged.
