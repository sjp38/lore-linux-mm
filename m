Date: Fri, 9 May 2003 08:57:48 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
In-Reply-To: <1052304024.9817.3.camel@rth.ninka.net>
Message-ID: <Pine.LNX.3.96.1030509085607.26434U-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7 May 2003, David S. Miller wrote:

> On Wed, 2003-05-07 at 03:10, Helge Hafting wrote:
> > 2.5.69-mm1 is fine, 2.5.69-mm2 panics after a while even under very
> > light load.
> 
> Do you have AF_UNIX built modular?
> 

This may be the same thing reported in
<20030505144808.GA18518@butterfly.hjsoft.com> earlier, it seems to happen
in 2.5.69 base. Interesting that he has it working in mm1, perhaps the
module just didn't get loaded.

Of course it could be another problem.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
