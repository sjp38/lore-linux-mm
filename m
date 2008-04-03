From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] SLQB: YASA
Date: Thu, 3 Apr 2008 16:23:26 +0200
Message-ID: <20080403142326.GA9878@wotan.suse.de>
References: <20080403072550.GC25932@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758309AbYDCOXh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080403072550.GC25932@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Apr 03, 2008 at 09:25:50AM +0200, Nick Piggin wrote:
> Hi,
> 
> I've been playing around with slab allocators because I'm concerned about
> the directions that SLUB is going in. I've come up so far with a working
> alternative implementation, which I have called SLQB (the remaining vowels
> are crap).

Oh, hmm, I think I messed up a hunk when merging in a patch here... so
this version is going to be buggy. I'll repost another tomorrow, so
nobody try to test this yet :)

Thanks,
Nick
