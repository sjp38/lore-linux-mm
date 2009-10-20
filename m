Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8BADF6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 17:52:40 -0400 (EDT)
Received: by fxm20 with SMTP id 20so6813904fxm.38
        for <linux-mm@kvack.org>; Tue, 20 Oct 2009 14:52:38 -0700 (PDT)
Message-ID: <4ADE3121.6090407@gmail.com>
Date: Tue, 20 Oct 2009 23:52:33 +0200
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org>	<20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>	<hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi and sorry for delay. Also, please CC me.

KAMEZAWA Hiroyuki wrote:

> On Tue, 13 Oct 2009 19:13:34 +0200
> Vedran FuraA? <vedranf@vedranf.mine.nu> wrote:
> 
>>> Against random-kill, you may have 2 choices.
>>>
>>> 1. use  /proc/<pid>/oom_adj 2. use  memory cgroup.
>>>
>>> Something more easy-to-use method may be appriciated. We have above 2
>>> now.
>> These are just bad workarounds for bad OOM algorithm. I tested this
>> little program on multiple systems (including windows) without any
>> tweaking and linux behavior is, unfortunately *the worst*.  :/
>>
> Yes, they are workaround. You can use /etc/sysctl.conf.
> But if making it default _now_, many threaded programs will not work.

Only Java ;) and only sometimes, at least from my experinence

> But I agree, OOM killer should be sophisticated.
> Please give us a sample program/test case which causes problem.
> linux-mm@kvack.org may be a better place. lkml has too much traffic.

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
  char *buf;
  while(1) {
    buf = malloc (1024*1024*100);
    if ( buf == NULL ) {
      perror("malloc");
      getchar();
      exit(EXIT_FAILURE);
    }
    sleep(1);
    memset(buf, 1, 1024*1024*100);
  }
  return 0;
}


After running this on a typical desktop with gnome or kde, OOM killer
will kill 5-10 innocent processes before killing this one. Tested
multiple times on multiple installations.

Regards,

Vedran


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
