Message-ID: <4365289.1109502351571.JavaMail.postfix@mx20.mail.sohu.com>
Date: Sun, 27 Feb 2005 19:05:51 +0800 (CST)
From: <stone_wang@sohu.com>
Subject: Re:Re: [PATCH] Linux-2.6.11-rc5: kernel/sys.c setrlimit() RLIMIT_RSS
 cleanup
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


I have a buddy who encountered the "ulimit" confusion,
when he and his team deployed Linux as the platform for a multi-user online programming test competition system.

And generally, i think the kernel/system shall work as it said(return of syscalls/output of commands) :)

But rss limit might be a historical issue, with already many applications depending on it :(

Stone Wang

-----  Original Message  -----
From: Andrew Morton 
To: stone_wang@sohu.com 
Cc: riel@redhat.com ;linux-mm@kvack.org ;linux-kernel@vger.kernel.org 
Subject: Re: [PATCH] Linux-2.6.11-rc5: kernel/sys.c setrlimit() RLIMIT_RSS
 cleanup
Sent: Sun Feb 27 18:31:36 CST 2005

> 
> <stone_wang@sohu.com> wrote:
> >
> > $ ulimit  -m 100000
> >  bash: ulimit: max memory size: cannot modify limit: Function not implemented
> 
> I don't know about this.  The change could cause existing applications and
> scripts to fail.  Sure, we'll do that sometimes but this doesn't seem
> important enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
