Message-Id: <l03130304b705d2c78ae5@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.30.0104201414400.20939-100000@fs131-224.f-secure.com>
References: 
        <Pine.LNX.4.33.0104191609500.17635-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 20 Apr 2001 12:50:05 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>, Rik van Riel <riel@conectiva.com.br>
Cc: Dave McCracken <dmc@austin.ibm.com>, "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Actually, this idea must have been in Unix since about
>> Bell Labs v5 Unix, possibly before.
>
>When people were happy they could sit down in front of a computer. But
>world changed since then. Users expectations are much higher, they want
>[among others] latency and high availability.
>
>> This is not a new idea, it's an old solution to an old
>> problem; it even seems to work quite well.
>
>Seems for who? AIX? "DON'T TOUCH IT!" I think HP-UX also has and it's
>not famous because of its stability. Sure, not because of this but maybe
>sometimes it contributes, maybe its design contributes, maybe its
>designers contribute.

Well, OK, let's look at a commercial UNIX known for stability at high load:
Solaris.  How does Solaris handle thrashing?

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
