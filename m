Date: Sun, 10 Oct 1999 20:21:15 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <14336.53971.896012.84699@light.alephnull.com>
Message-ID: <Pine.LNX.4.10.9910102015030.4696-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik Faith <faith@precisioninsight.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> No.  The DRI assumes that direct-rendering clients are running as non-root
> users.  A direct-rendering client, with an open connection to the X server,
> is allowed to mmap the MMIO region via a special device (additional
> restrictions also apply).  For more information, please see "A Security
> Analysis of the Direct Rendering Infrastructure"
> (http://precisioninsight.com/dr/security.html).

> Just to clarify, the DRI does _not_ require that clients be SUID.

Oh my. Non root and direct access to buggy hardware. 

Yeah since your familar with SGI can you explain to me the use of 
/dev/shmiq, /dev/qcntl and /dev/usemaclone. I have seen them used for the
X server on IRIX and was just interested to see if they could be of use on
other platforms. Yes SGI linux supports these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
