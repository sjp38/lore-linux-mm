Date: Sat, 21 Sep 2002 16:53:51 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: overcommit stuff
Message-ID: <20020921235351.GC25605@holomorphy.com>
References: <3D8D0046.EF119E03@digeo.com> <Pine.LNX.4.44.0209220037110.2265-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0209220037110.2265-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 22, 2002 at 12:46:59AM +0100, Hugh Dickins wrote:
> I don't think Alan can be held responsible for errors in the
> overcommit stuff rml ported to 2.5 and I then added fixes to.
> I believe it is up to date in 2.5.
> Committed_AS certainly errs on the pessimistic side, that's
> what it's about.  How much swap do you have i.e. is 23GB
> committed impossible, or just surprising to you?  Does the
> number go back to what it started off from when you kill
> off the tests?  How are "those pages" allocated e.g. what
> mmap args?
> Hugh

In my case it's not really possible to rerun a test in the same
boot. It's not really survived very often, and when it has, it
generally fails to start a second time. Various other things feel the
OOM sting then, e.g. kernel compiles, small task count dbench, etc.

Some of this might be slab, but I think there might be a leak.
The best answers I've come up with thus far are "Hrm, the OOM killer
gets set off at the wrong times, and maybe delalloc would kill bh's?"

Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
