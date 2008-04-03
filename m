From: Christoph Lameter <clameter@sgi.com>
Subject: Re: EMM: disable other notifiers before register and unregister
Date: Thu, 3 Apr 2008 13:23:12 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804031321260.8331@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com> <20080401205635.793766935@sgi.com>
 <20080402064952.GF19189@duo.random> <Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
 <20080402220148.GV19189@duo.random> <Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
 <20080402221716.GY19189@duo.random> <Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
 <20080403151908.GB9603@duo.random> <Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758767AbYDCU0J@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-Id: linux-mm.kvack.org

On Thu, 3 Apr 2008, Christoph Lameter wrote:

> > faults). So it should be ok to take all those locks inside the
> > mmap_sem and implement a lock_vm(mm) unlock_vm(mm). I'll think more
> > about this hammer approach while I try to implement it...
> 
> Well good luck. Hopefully we will get to something that works.

Another hammer to use may be the freezer from software suspend. With that 
you can get all tasks of a process into a definite state. Then take the 
mmap_sem writably. But then there is still try_to_unmap and friends that 
can race.
