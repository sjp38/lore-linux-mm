Subject: Re: [PATCH] shm fs v2 against 2.3.41
References: <qwwemazzj8u.fsf@sap.com> <20000201190720E.gotom@fe.dis.titech.ac.jp>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 01 Feb 2000 13:46:25 +0100
In-Reply-To: GOTO Masanori's message of "Tue, 01 Feb 2000 19:07:20 +0900"
Message-ID: <qwwiu095bvi.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: GOTO Masanori <gotom@debian.or.jp>
Cc: linux-kernel@vger.rutgers.edu, linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

GOTO Masanori <gotom@debian.or.jp> writes:

> Calling shmget( key, size, shmflg ) with size = 0,
> I got an error EINVAL. The below patch fix it,
> please apply into 2.3.41+shmfs14 patch.
> 
> ---------------------
> --- linux-2.3.41_shmfs14/ipc/shm.c      Tue Feb  1 18:49:02 2000
> +++ linux-2.3.41_shmfs14_fixed/ipc/shm.c        Tue Feb  1 18:57:52 2000
> @@ -660,7 +660,7 @@
>                 return -EINVAL;
>         }
>  
> -       if (size < SHMMIN)
> +       if ((size != 0) && (size < SHMMIN))
>                 return -EINVAL;
>  
>         down(&shm_ids.sem);
> ---------------------

Yes, I stumbled over that yesterday evening also. I will put out a new
patch soon.

> And now I have a question:
> I guess almost all users have no shmpath (default: /var/shm),
> and they maybe make a dir and have to mount it.
> IMHO, it is better to change that sysv shared memory works
> samely, whenever shmfs is not mounted. Is it feasible, 
> or only my mistaken ?

This was my first attempt, but all the gurus opposed to that since
this needed some hacks to the VFS layer.

Since shmat, etc rely on the VFS functions, we have to mount the fs to
use these functions.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
