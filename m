From: Christoph Rohland <cr@sap.com>
Subject: Re: shmfs/tmpfs/vm-fs
References: <01120616545301.04747@hishmoom> <m34rn3jobk.fsf@linux.local>
	<01120712372904.00795@hishmoom>
Date: 07 Dec 2001 16:07:44 +0100
Message-ID: <m3vgfjjcfz.fsf@linux.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lothar.maerkle@gmx.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Lothar,

On Fri, 7 Dec 2001, der erste Schuettler wrote:
> thanks for the paper but, with sysvipc, are msyncs still needed, to
> keep the shared pages in sync with the file on the tmpfs? 

Of course not. sync on tmpfs does nothing.

> You could use the same pages for all...  tmpfs ist cool, is it
> possible to change the permissions on an shared object or istead of
> shmctl IPC_RMID just use rm /de/shm/SYSVblablub?

It was possible in some 2.3 kernels, but this had to be removed with
the cleanup :-(

Greetings
		Christoph


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
