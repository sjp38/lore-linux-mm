Subject: Re: page->virtual is null
Message-ID: <OF1A405C85.1E5817FB-ON65256DF7.0034BDE5@in.ibm.com>
From: Vinod K Suryan <visuryan@in.ibm.com>
Date: Tue, 9 Dec 2003 15:41:55 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




HI,

      source code location is


http://www.openafs.org/cgi-bin/cvsweb.cgi/openafs/src/afs/LINUX/osi_vnodeops.c
  1.69 version

      or
http://www.openafs.org/cgi-bin/cvsweb.cgi/openafs/src/afs/LINUX/osi_vnodeops.c?rev=1.69&content-type=text/x-cvsweb-markup


      afs_linux_readpage : in this function kmap is returning NULL,
      i checked pp->virtual is NULL.
      When i  read some files or write something to the file it is giving
"bad address"
      when i am going through symlink system is getting panic..

Thanks
Vinod Suryan


>
> Hi,
>       I am using SMP machine with 256 MB Ram. I am using kmap function in
> my application it is returning NULL value.

can you post a pointer (URL or so) to the source code so that we can see
a bit of context ?


      I am using SMP machine with 256 MB Ram. I am using kmap function in
my application it is returning NULL value.

      Here is some log

      highmem_start_page = c13bf8ac
      page address is =    c132a194

      but after kmap i am getting readpage:kmap address is NULL=0

      here kmap is returning page->virtual which value is NULL

      after that i am getting badaddress error.

      but same code is working fine in uni-processor. i am getting

      i am using 2.4.21-4.EL kernel ..

      please help me..
      i am not geting wht to do..?

Thanks
Vinod Suryan

#### signature.asc has been removed from this note on December 09 2003 by
Vinod K Suryan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
