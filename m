Message-Id: <200505181618.j4IGI0g09238@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
Date: Wed, 18 May 2005 09:18:00 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
In-Reply-To: <17035.25471.122512.658772@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Wolfgang Wander' <wwc@rentec.com>
Cc: =?iso-8859-1?Q?Herv=E9_Piedvache?= <herve@elma.fr>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wolfgang Wander wrote on Wednesday, May 18, 2005 8:47 AM
> I have to retract my earlier statement partially.  While this patch
> does address the problems with munmap's tendency to fragment the maps
> areas, the issue it does not address, namely the lack of concentrating
> smaller requests towards the base is indeed important to us.
> 
> With your patch the two large applications that triggered the
> fragmentation issue do still fail. So we still have a regression from
> 2.4 kernels to 2.6 with this fix.
> 
> So I'd vote (hope it counts ;-) to either include your munmap
> improvements into my earlier avoiding-fragmentation-fix or use
> my (admittedly more complex) patch instead.
> 
> I will append both a test case and the (nearly) final
> /proc/self/maps status of our failing application (cleansed slightly)
> 
> The application fails with a request for 250MB but still had more
> than 1GB of memory distributed over the various holes.  All
> maps are allocated via standard malloc/free calls which glibc
> translates into brk/mmap calls.

Yeah, it's going to be a challenge to satisfy a very large mmap mixed
with tons of small mmap/munmap.  I would think a truly random mmap/munmap
size would coalesce mapping nicely.  But apparently not in your case.  I
will keep digging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
