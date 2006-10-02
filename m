Message-ID: <45216233.5010602@RedHat.com>
Date: Mon, 02 Oct 2006 15:02:11 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com>	<20060925141036.73f1e2b3.akpm@osdl.org>	<45185D7E.6070104@yahoo.com.au>	<451862C5.1010900@oracle.com>	<45186481.1090306@yahoo.com.au>	<45186DC3.7000902@oracle.com>	<451870C6.6050008@yahoo.com.au>	<4518835D.3080702@oracle.com>	<451886FB.50306@yahoo.com.au>	<451BF7BC.1040807@oracle.com>	<20060928093640.14ecb1b1.akpm@osdl.org>	<20060928094023.e888d533.akpm@osdl.org>	<451BFB84.5070903@oracle.com>	<20060928100306.0b58f3c7.akpm@osdl.org>	<451C01C8.7020104@oracle.com>	<451C6AAC.1080203@yahoo.com.au>	<451D8371.2070101@oracle.com>	<1159562724.13651.39.camel@lappy>	<451D89E7.7020307@oracle.com>	<1159564637.13651.44.camel@lappy>	<20060929144421.48f9f1bd.akpm@osdl.org>	<451D94A7.9060905@oracle.com>	<20060929152951.0b763f6a.akpm@osdl.org>	<451F425F.8030609@oracle.com>	<4520FFB6.3040801@RedHat.com>	<1159795522.6143.7.camel@lade.trondhjem.org>	<20061002095727.05cd052f.akpm@osdl.org>	<4521460B.8000504@RedHat.com> <20061002112005.d02f84f7.akpm@osdl.o!
 rg>
In-Reply-To: <20061002112005.d02f84f7.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, chuck.lever@oracle.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:
> 
> This is our user's data we're talking about here.
Point...

> 
> If that printk comes out then we need to fix the kernel so that it no
> longer wants to print that printk.  We don't want to just hide it.
I'm concern about the printk popping when we are flushing the
readdir cache (i.e. stale data) and either flooding the console
to a ton a messages (basically bring a system to its knees for
no good reason) or scaring the hell out people by saying we have a
major problem when in reality we are just flushing stale data...

So I definitely agree the printk should be there and be on by default,
but I so think it would be a good idea to have way to turn it off
if need be...

steved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
