Reply-To: <martin.frey@compaq.com>
From: "Martin Frey" <frey@scs.ch>
Subject: RE: Kernel Debugger
Date: Wed, 16 May 2001 07:42:53 -0400
Message-ID: <009701c0ddfd$5817c0f0$bd56d2d0@SCHLEPPDOWN>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <3B02007A.E9257BA2@wipro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: amarnath.jolad@wipro.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
>Is there any kernel debugger for linux like 
>adb/crash/kadb. If so,  from
>where can I get them.
>
http://oss.missioncriticallinux.com

mcore and crash work fine for me. I used it on
Alpha, but is is supposed to work on Intel and
PowerPC as well.
The patches are against 2.2.16 and 2.4.0testX,
but applying it on 2.4.2 is easy.
I can send you a diff for 2.4.2 if you need.

Regards,

Martin Frey

-- 
Supercomputing Systems AG       email: frey@scs.ch
Martin Frey                     web:   http://www.scs.ch/~frey/
at Compaq Computer Corporation  phone: +1 603 884 4266
ZKO2-3P09, 110 Spit Brook Road, Nashua, NH 03062

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
