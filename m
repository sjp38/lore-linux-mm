Message-Id: <l0313032ab6e528bcd610@[192.168.239.101]>
In-Reply-To: <3ABF6EA0.A2454B66@linuxjedi.org>
References: 
        <Pine.LNX.4.21.0103261258270.1863-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 26 Mar 2001 18:15:56 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: memory mgmt/tuning for diskless machines
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David L. Parsley" <parsley@linuxjedi.org>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>I'll try to search for his patch in kernel archives and let you know how
>it works out.
>
>Jonathan - if you could ship me the patch I'd appreciate it, but I'll
>try searching first.

Search the last few days for a post beginning "[TAKE3] [PATCH]"...

Note there is a bug in the accounting which appears to be able to cause the
count of reserved memory to go negative under some circumstances.  I
triggered it by starting 4 copies of the Blackdown Java 1.2.2 VM, then
closing them.  With the patch enabled, two extra fields appear in
/proc/meminfo for monitoring.

Note also that I'm not sbscribed on the linux-mm list (perhaps I should
be), so please CC me.

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
