Date: Mon, 15 Nov 1999 17:39:00 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: 128M with kernel 2.2.5-15 and RH6.0
In-Reply-To: <Pine.LNX.4.10.9911151321090.1122-100000@robleda.iit.upco.es>
Message-ID: <Pine.LNX.4.10.9911151737360.6561-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesus Peco <peco@iit.upco.es>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 1999, Jesus Peco wrote:

> I have tried to write de line:
> 
> append = "mem=128M"

try something like:

image=/boot/vmlinuz
        label=Linux
        root=/dev/hda1
        read-only
        append="mem=128m"

note that there are no whitespaces after 'append'.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
