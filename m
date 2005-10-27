From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Date: Thu, 27 Oct 2005 21:56:02 +0200
References: <E1EVDbZ-0004fp-00@w-gerrit.beaverton.ibm.com>
In-Reply-To: <E1EVDbZ-0004fp-00@w-gerrit.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510272156.03276.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Badari Pulavarty <pbadari@us.ibm.com>, andrea@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 27 October 2005 21:40, Gerrit Huizenga wrote:

>  I believe Java uses mmap() today for this; DB2 probably uses both mmap()
>  and shm*().

In the java case the memory should be anonymous, no? This means just plain
munmap would work. Or do I miss something?

-Andi

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
