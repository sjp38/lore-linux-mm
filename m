Message-ID: <446753AA.7040700@shadowen.org>
Date: Sun, 14 May 2006 16:58:34 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
References: <1146861313.3561.13.camel@lappy>	<445CA22B.8030807@cyberone.com.au>	<1146922446.3561.20.camel@lappy>	<445CA907.9060002@cyberone.com.au>	<1146929357.3561.28.camel@lappy>	<Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>	<1147116034.16600.2.camel@lappy>	<Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>	<1147207458.27680.19.camel@lappy>	<20060511080220.48688b40.akpm@osdl.org>	<Pine.LNX.4.64.0605111546480.16571@schroedinger.engr.sgi.com>	<Pine.LNX.4.64.0605111616490.3866@g5.osdl.org> <20060511164448.4686a2bd.akpm@osdl.org>
In-Reply-To: <20060511164448.4686a2bd.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, clameter@sgi.com, a.p.zijlstra@chello.nl, piggin@cyberone.com.au, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Linus Torvalds <torvalds@osdl.org> wrote:
> 
>>What happened to the VM stress-test programs that we used to test the 
>>page-out with? I forget who kept a collection of them around, but they did 
>>things like trying to cause MM problems on purpose.
> 
> 
> I think that was me, back in my programming days.
> 
> 
>>And I'm pretty sure 
>>some of the nastiest ones used shared mappings, exactly because we've had 
>>problems with the virtual scanning.
> 
> 
> http://www.zip.com.au/~akpm/linux/patches/stuff/ext3-tools.tar.gz
> 
> run-bash-shared-mapping.sh is a good stress-tester and deadlock-finder.

Well my amd64 box ran run-bash-shared-mapping.sh for 6 hours without a
peep or oops.  Machine seemed ok at the end.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
