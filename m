Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8PK0UDq004883
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 06:00:30 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8PK44Wm278668
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 06:04:05 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8PJx0t3026978
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 05:59:00 +1000
Message-ID: <46F968C2.7080900@linux.vnet.ibm.com>
Date: Wed, 26 Sep 2007 01:30:02 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.6.23-rc8-mm1 - powerpc memory hotplug link failure
References: <20070925014625.3cd5f896.akpm@linux-foundation.org>
In-Reply-To: <20070925014625.3cd5f896.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

The 2.6.23-rc8-mm1 kernel linking fails on the powerpc (P5+) box

  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
drivers/built-in.o: In function `memory_block_action':
/root/scrap/linux-2.6.23-rc8/drivers/base/memory.c:188: undefined reference to `.remove_memory'
make: *** [.tmp_vmlinux1] Error 1

# gcc -v
Using built-in specs.
Target: powerpc64-suse-linux
Configured with: ../configure --enable-threads=posix --prefix=/usr 
--with-local-prefix=/usr/local --infodir=/usr/share/info 
--mandir=/usr/share/man --libdir=/usr/lib --libexecdir=/usr/lib 
--enable-languages=c,c++,objc,fortran,obj-c++,java,ada 
--enable-checking=release --with-gxx-include-dir=/usr/include/c++/4.1.2 
--enable-ssp --disable-libssp --disable-libgcj --with-slibdir=/lib 
--with-system-zlib --enable-shared --enable-__cxa_atexit 
--enable-libstdcxx-allocator=new --program-suffix=-4.1 
--enable-version-specific-runtime-libs --without-system-libunwind 
--with-cpu=default32 --enable-secureplt --with-long-double-128 --host=powerpc64-suse-linux
Thread model: posix
gcc version 4.1.2 20061115 (prerelease) (SUSE Linux)

 # ld -v
GNU ld version 2.17.50.0.5 20060927 (SUSE Linux)


-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
