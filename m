Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.39-mm1
Date: Sun, 29 Sep 2002 21:24:12 -0400
References: <3D976206.B2C6A5B8@digeo.com>
In-Reply-To: <3D976206.B2C6A5B8@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209292124.12696.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On September 29, 2002 04:26 pm, Andrew Morton wrote:
> There is a reiserfs compilation problem at present.

make[2]: Entering directory `/poole/src/39-mm1/fs/reiserfs'
  gcc -Wp,-MD,./.bitmap.o.d -D__KERNEL__ -I/poole/src/39-mm1/include -Wall -Wstrict-prototypes -Wno-trigraphs -O2 -fomit-frame-pointer -fno-strict-aliasing -fno-common -pipe -mpreferred-stack-boundary=2 -march=k6 -I/poole/src/39-mm1/arch/i386/mach-generic -nostdinc -iwithprefix include    -DKBUILD_BASENAME=bitmap   -c -o bitmap.o bitmap.c
In file included from bitmap.c:8:
/poole/src/39-mm1/include/linux/reiserfs_fs.h:1635: parse error before `reiserfs_commit_thread_tq'
/poole/src/39-mm1/include/linux/reiserfs_fs.h:1635: warning: type defaults to `int' in declaration of `reiserfs_commit_thread_tq'
/poole/src/39-mm1/include/linux/reiserfs_fs.h:1635: warning: data definition has no type or storage class
make[2]: *** [bitmap.o] Error 1
make[2]: Leaving directory `/poole/src/39-mm1/fs/reiserfs'
make[1]: *** [reiserfs] Error 2
make[1]: Leaving directory `/poole/src/39-mm1/fs'
make: *** [fs] Error 2

which is:

extern task_queue reiserfs_commit_thread_tq ;

from bk chanages:

ChangeSet@1.644, 2002-09-29 11:00:25-07:00, mingo@elte.hu
  [PATCH] smptimers, old BH removal, tq-cleanup

<omitted>

   - removed the ability to define your own task-queue, what can be done is
     to schedule_task() a given task to keventd, and to flush all pending
     tasks.

Ingo?

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
