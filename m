Message-Id: <l03130306b705d43ce2c0@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
References: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Date: Fri, 20 Apr 2001 13:02:11 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>, "James A. Sutherland" <jas88@cam.ac.uk>
Cc: Dave McCracken <dmc@austin.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> More to the point, though, what about the worst case, where every
>> process is thrashing?
>
>What about the simplest case when one process thrasing? You suspend it
>continuously from time to time so it won't finish e.g. in 10 minutes but
>in 1 hour.

One process thrashing, lots of other processes behaving sensibly.  With the
current page-replacement policy, active memory belonging to well-behaved
processes will be regularly paged out (a Bad Thing?), whether the thrashing
process is suspended periodically or not.  The suspensions simply reduce
the frequency of this a little.

Where *every* process is thrashing, you have to suspend lots of processes
in order to get the rest to run.  Also, every time you change the set of
suspended processes, you have to wait for the VM to settle before the peak
useful work is being done again, and even longer than that before you can
sensibly change the set of suspended processes again.  This is *very*
granular - of the order of tens of seconds for a medium-sized PC-type
computer.

We need a better page-replacement algorithm, and I think my suggestion goes
some way towards that.  Who knows, I might even attempt to implement it
next week...

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
