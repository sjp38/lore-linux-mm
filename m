Message-ID: <3ABB9CF2.E7715667@evision-ventures.com>
Date: Fri, 23 Mar 2001 19:58:58 +0100
From: Martin Dalecki <dalecki@evision-ventures.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Prevent OOM from killing init
References: <E14gVQf-00056B-00@the-village.bc.nu>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "James A. Sutherland" <jas88@cam.ac.uk>, Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I have a constructive proposal:

It would make much sense to make the oom killer
leave not just root processes alone but processes belonging to a UID
lower
then a certain value as well (500). This would be:

1. Easly managable by the admin. Just let oracle/www and analogous users
   have a UID lower then let's say 500.

2. In full compliance with the port trick done by TCP/IP (ports < 1024
vers other)

3. It wouldn't need any addition of new interface (no jebanoje gawno in
/proc in addition()

4. Really simple to implement/document understand.

5. Be the same way as Solaris does similiar things.

...


Damn: I will let my chess club alone toady and will just code it down
NOW.

Spec:

1. Processes with a UID < 100 are immune to OOM killers.
2. Processes with a UID >= 100 && < 500 are hard for the OOM killer to
take on.
3. Processes with a UID >= 500 are easy targets.

Let me introduce a new terminology in full analogy to "fire walls"
routers and therabouts:

Processes of category 1. are called captains (oficerzy)
Processes of category 2. are called corporals (porucznicy)
Processes of category 2. are called privates (?o3nierze)

;-)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
