Message-ID: <20000110145913.01335@colin.muc.de>
From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] replace SYSV shared memory with shm filesystem
References: <qwwvh52ruin.fsf_-_@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <qwwvh52ruin.fsf_-_@sap.com>; from Christoph Rohland on Mon, Jan 10, 2000 at 01:20:40PM +0100
Date: Mon, 10 Jan 2000 14:59:14 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Alexander Viro <viro@math.psu.edu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, GOTO Masanori <gotom@debian.or.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 10, 2000 at 01:20:40PM +0100, Christoph Rohland wrote:
> Hi folks,
> 
> This patch implements a minimal filesystem for shared memory. It
> replaces/reuses the existing SYSV shm code so you now have to mount
> the fs to be able to use SYSV SHM. But in turn we now have everything
> in place to implement posix shm. This also obsoletes vm_private_data
> in vm_area_struct.

I planed to map the Unix Sockets abstract name space to a file system
for some time now.  Because it would be silly to write another file
system just for that rather obscure feature, would it be possible
to use a subdirectory in your new shm filesystem? I haven't looked
at the code at all yet, and don't know if it can even deal with 
directories and special devices. Do you have objections to such 
a direction?

-Andi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
