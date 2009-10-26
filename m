Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 92B9C6B005A
	for <linux-mm@kvack.org>; Sun, 25 Oct 2009 22:01:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9Q1vX0D019928
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 26 Oct 2009 10:57:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B4FE2AEA8D
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 10:57:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DF94845DE4E
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 10:57:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B95C3E38002
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 10:57:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CB111DB803C
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 10:57:32 +0900 (JST)
Date: Mon, 26 Oct 2009 10:55:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4ADE3121.6090407@gmail.com>
References: <hav57c$rso$1@ger.gmane.org>
	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
	<hb2cfu$r08$2@ger.gmane.org>
	<20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	<4ADE3121.6090407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Oct 2009 23:52:33 +0200
Vedran FuraA? <vedran.furac@gmail.com> wrote:

> Hi and sorry for delay. Also, please CC me.

> > But I agree, OOM killer should be sophisticated.
> > Please give us a sample program/test case which causes problem.
> > linux-mm@kvack.org may be a better place. lkml has too much traffic.
> 
> #include <stdio.h>
> #include <string.h>
> #include <stdlib.h>
> #include <unistd.h>
> 
> int main()
> {
>   char *buf;
>   while(1) {
>     buf = malloc (1024*1024*100);
>     if ( buf == NULL ) {
>       perror("malloc");
>       getchar();
>       exit(EXIT_FAILURE);
>     }
>     sleep(1);
>     memset(buf, 1, 1024*1024*100);
>   }
>   return 0;
> }
> 
> 
> After running this on a typical desktop with gnome or kde, OOM killer
> will kill 5-10 innocent processes before killing this one. Tested
> multiple times on multiple installations.
> 
> Regards,
> 
Can I make more questions ?

 - What's cpu ?
 - How much memory ?
 - Do you have swap ?
 - What's the latest kernel version you tested?
 - Could you show me /var/log/dmesg and /var/log/messages at OOM ?
 
Thanks,
-Kame



> Vedran
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
