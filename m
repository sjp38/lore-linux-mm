Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF6A6B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 00:17:23 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so7847329pbb.24
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 21:17:23 -0700 (PDT)
Received: by mail-la0-f43.google.com with SMTP id ep20so6444844lab.16
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 21:17:19 -0700 (PDT)
Date: Thu, 19 Sep 2013 06:14:55 +0200
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: shouldn't gcc use swap space as temp storage??
Message-ID: <20130919041451.GA2082@hp530>
References: <1379445730.79703.YahooMailNeo@web172205.mail.ir2.yahoo.com>
 <1379550301.48901.YahooMailNeo@web172202.mail.ir2.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1379550301.48901.YahooMailNeo@web172202.mail.ir2.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max B <txtmb@yahoo.fr>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Sep 19, 2013 at 01:25:01AM +0100, Max B wrote:
> 
> 
> 
> 
> 
> 
> Hi All,
> 
> See below for executable program.
> 
> 
> Shouldn't gcc use swap space as temp storage?? Either my machine is set up improperly, or gcc does not (cannot?) access this capability.
> 
> 
> It seems to me that programs should be able to access swap memory in these cases, but the behaviour has not been confirmed.
> 
> Can someone please confirm or correct me?
> 

It is not because your machine settings or gcc. Your code is buggy.

> 
> Apologies if this is not the correct listserv for the present discussion.
> 

I think the proper list for C related questions is linux-c-programming or similar.

Vladimir

> 
> Thanks for any/all help.
> 
> 
> Cheers,
> Max
> 
> 
> /*
> ?* This program segfaults with the *bar array declaration.
> ?*
> ?* I wonder why it does not write the *foo array to swap space
> ?* then use the freed ram to allocate *bar.
> ?*
> ?* I have explored the shell ulimit parameters to no avail.
> ?*
> ?* I have run this as root and in userland with the same outcome.
> ?*
> ?* It seems to be a problem internal to gcc, but may also be a kernel issue.
> ?*
> ?*/
> 
> #include <stdio.h>
> #include <stdlib.h>
> 
> #define NMAX 628757505
> 
> int main(int argc,char **argv) {
> ? float *foo,*bar;
> 
> ? foo=calloc(NMAX,sizeof(float));
> ? fprintf(stderr,"%9.3f %9.3f\n",foo[0],foo[1]);
> #if 1
> ? bar=calloc(NMAX,sizeof(float));
> ? fprintf(stderr,"%9.3f %9.3f\n",bar[0],bar[1]);
> #endif
> 
> ? return
>  0;
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
