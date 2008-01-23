Received: by wa-out-1112.google.com with SMTP id m33so4940279wag.8
        for <linux-mm@kvack.org>; Wed, 23 Jan 2008 05:09:12 -0800 (PST)
Message-ID: <4df4ef0c0801230509w5c6cd1a5m35fb30b51462da4d@mail.gmail.com>
Date: Wed, 23 Jan 2008 16:09:11 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v8 3/4] Enable the MS_ASYNC functionality in sys_msync()
In-Reply-To: <E1JHcG4-0002A9-46@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
	 <1201044083504-git-send-email-salikhmetov@gmail.com>
	 <1201078035.6341.45.camel@lappy> <1201078278.6341.47.camel@lappy>
	 <E1JHc0S-00027S-8D@pomaz-ex.szeredi.hu>
	 <E1JHcG4-0002A9-46@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/23, Miklos Szeredi <miklos@szeredi.hu>:
> > > Also, it still doesn't make sense to me why we'd not need to walk the
> > > rmap, it is all the same file after all.
> >
> > It's the same file, but not the same memory map.  It basically depends
> > on how you define msync:
> >
> >  a) sync _file_ on region defined by this mmap/start/end-address
> >  b) sync _memory_region_ defined by start/end-address
>
> My mmap/msync tester program can acually check this as well, with the
> '-f' flag.  Anton, can you try that on the reference platforms?

Here it is:

$ ./a.out file -f
begin   1201085546      1201085546      1200956936
write   1201085546      1201085546      1200956936
mmap    1201085546      1201085546      1200956936
b       1201085546      1201085546      1200956936
msync b 1201085550      1201085550      1200956936
c       1201085550      1201085550      1200956936
msync c 1201085552      1201085552      1200956936
d       1201085552      1201085552      1200956936
munmap  1201085552      1201085552      1200956936
close   1201085555      1201085555      1200956936
sync    1201085555      1201085555      1200956936
$ ./a.out file -sf
begin   1201085572      1201085572      1200956936
write   1201085572      1201085572      1200956936
mmap    1201085572      1201085572      1200956936
b       1201085572      1201085572      1200956936
msync b 1201085576      1201085576      1200956936
c       1201085576      1201085576      1200956936
msync c 1201085578      1201085578      1200956936
d       1201085578      1201085578      1200956936
munmap  1201085578      1201085578      1200956936
close   1201085581      1201085581      1200956936
sync    1201085581      1201085581      1200956936
$ uname -a
FreeBSD td152.testdrive.hp.com 6.2-RELEASE FreeBSD 6.2-RELEASE #0: Fri
Jan 12 11:05:30 UTC 2007
root@dessler.cse.buffalo.edu:/usr/obj/usr/src/sys/SMP  i386
$

>
> Miklos
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
