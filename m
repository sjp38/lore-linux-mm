Message-Id: <l03130312b708cf8a37bf@[192.168.239.105]>
In-Reply-To: <re36et84buhdc4mm252om30upobd8285th@4ax.com>
References: <l03130311b708b57e1923@[192.168.239.105]>
 <l0313030fb70791aa88ae@[192.168.239.105]>
 <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com>
 <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
 <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com>
 <3AE1DCA8.A6EF6802@earthlink.net>
 <l0313030fb70791aa88ae@[192.168.239.105]>
 <54b5et09brren07ta6kme3l28th29pven4@4ax.com>
 <l03130311b708b57e1923@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 22 Apr 2001 19:18:19 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>No, it doesn't.  If we stick with the current page-replacement policy, then
>>regardless of what we do with the size of the timeslice, there is always
>>going to be the following situation:
>
>This is not just a case of increasing the timeslice: the suspension
>strategy avoids the penultimate stage of this list happening:
>
>>- Large process(es) are thrashing.
>>- Login needs paging in (is suspended while it waits).
>>- Each large process gets it's page and is resumed, but immediately page
>>faults again, gets suspended
>>- Memory reserved for Login gets paged out before Login can do any useful
>>work
>
>Except suspended processes do not get scheduled for a couple of
>seconds, meaning login CAN do useful work.

But login was suspended because of a page fault, so potentially it will
*also* get suspended for just as long as the hogs.  Unless, of course, the
suspension time is increased with page fault count per process.

>Not really. Your WS suggestion doesn't evict some processes entirely,
>which is necessary under some workloads.

Can you give an example of such a workload?

>Distributing "fairly" is sub-optimal: sequential suspension and
>resumption of each memory hog will yield far better performance. To
>the extent some workloads fail with your approach but succeed with
>mine: if a process needs more than the current working-set in RAM to
>make progress, your suggestion leaves each process spinning, taking up
>resources.

I think we're approaching the problem from opposite viewpoints.  Don't get
me wrong here - I think process suspension could be a valuable "feature"
under extreme load, but I think that the working-set idea will perform
better and more consistently under "mild overloads", which the current
system handles extremely poorly.  Probably the only way to resolve this
argument is to actually try and implement each idea, and see how they
perform.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
