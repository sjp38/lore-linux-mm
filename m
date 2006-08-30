Received: by wr-out-0506.google.com with SMTP id i4so111191wra
        for <linux-mm@kvack.org>; Wed, 30 Aug 2006 11:02:00 -0700 (PDT)
Message-ID: <eada2a070608301101j205b2711va5c287dbf8aab492@mail.gmail.com>
Date: Wed, 30 Aug 2006 11:01:58 -0700
From: "Tim Pepper" <tpepper@gmail.com>
Subject: Re: libnuma interleaving oddness
In-Reply-To: <200608300932.23746.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060829231545.GY5195@us.ibm.com> <200608300919.13125.ak@suse.de>
	 <20060830072948.GE5195@us.ibm.com> <200608300932.23746.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On 8/30/06, Andi Kleen <ak@suse.de> wrote:
> Then it's probably some new problem in hugetlbfs.

It's something subtle though, because I _am_ able to get interleaving
on hugetlbfs with a slightly simplified test case (see previous email)
compared to Nish's.

> Does it work with shmfs?

Haven't tried shmfs, but the following correctly does the expected
interleaving with hugepages (although not hugetlbfs backed):
     shmid = shmget( 0, NR_HUGE_PAGES, IPC_CREAT | SHM_HUGETLB | 0666 );
     shmat_addr = shmat( shmid, NULL, 0 );
     ...
     numa_interleave_memory( shmat_addr, SHM_SIZE, &nm );
I'd expect it works fine with non-huge pages, shmfs.

> The regression test for hugetlbfs is numactl is unfortunately still disabled.
> I need to enable it at some point for hugetlbfs now that it reached mainline.

On my list of random things to do is trying to improve the test
coverage in this area.  We keep running into bugs or possible bugs or
confusion on expected behaviour.  I'm going through the code trying to
understand it and writing little programs to confirm my understanding
here and there anyway.


Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
