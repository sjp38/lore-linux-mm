Date: Fri, 02 Aug 2002 16:54:53 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: large page patch (fwd) (fwd)
Message-ID: <92200000.1028332493@flay>
In-Reply-To: <Pine.LNX.4.33.0208021252090.2466-100000@penguin.transmeta.com>
References: <Pine.LNX.4.33.0208021252090.2466-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hubertus Franke <frankeh@watson.ibm.com>, wli@holomorpy.com, gh@us.ibm.com, akpm@zip.com.au, swj@cse.unsw.edu.au, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> Let me than turn around the table. Have you looked at our patch for 2.4.18.
>> It doesn't add anything to the hot path either, if the (vma->pg_order == 0).   
>> Period.
> 
> Nobody has forwarded the patch, and I've seen no discussion of it on the
> kernel mailing lists.
> 
> Guess what the answer is?
> 
> Is it 10 lines of code in the VM subsystem?

No, and you're not going to like the patch in it's current incarnation by
the sound of it. So, having listened to your objections, we're going to
take a slightly different course - we will prepare a minimal version of
the patch with very low impact on the core VM code, but using more 
standard interfaces to access it (eg the shmem method you outlined
earlier). It'll have a little less functionality, but so be it.

There are other apps apart from Oracle that want the ability to use large
pages (eg DB2 and Java), and it seems that most of those want them for 
anonymous mmap or shmem. If we can provide an interface that's more 
standard, it'll make people's porting much easier. IBM Research has done
some significant benchmarking of large page support in a variety of
applications, and has seen 20-40% performance boost for Java, and 
6-22% improvment for the SPEC CPU2000 set of tests. For the full 
details, see the OLS paper at:
http://www.linux.org.uk/~ajh/ols2002_proceedings.pdf.gz
Moreover, we need large pages to reduce PTE consumption in a variety
of applications using shared memory, especially given the additional
overhead of rmap.

We should have this available in a few days - if you could hold off 
until then, we should be able to do an objective comparison? I believe
we can make something that's acceptable to you.

Thanks,

Martin.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
