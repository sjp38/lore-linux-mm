Date: Tue, 24 Sep 2002 19:55:10 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.38-mm2 pdflush_list
Message-ID: <20020925025510.GQ6070@holomorphy.com>
References: <20020925022324.GP6070@holomorphy.com> <3D912577.160421F8@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D912577.160421F8@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> There's a NULL in this circular list:

On Tue, Sep 24, 2002 at 07:54:47PM -0700, Andrew Morton wrote:
> The only way I can see this happen is if someone sprayed out
> a bogus wakeup.  Are you using preempt (or software suspend??)

Nope. Just SMP. Happened on the NUMA-Q's. I couldn't figure out
what was going on from this. It's still up for postmortem, though.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
