Message-ID: <46B8E227.1010300@tmr.com>
Date: Tue, 07 Aug 2007 17:20:39 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl> <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu> <200708050051.40758.ctpm@ist.utl.pt>
In-Reply-To: <200708050051.40758.ctpm@ist.utl.pt>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Claudio Martins <ctpm@ist.utl.pt>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>, =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

Claudio Martins wrote:
> On Saturday 04 August 2007, Alan Cox wrote:
>> Linux has never been a "suprise your kernel interfaces all just changed
>> today" kernel, nor a "gosh you upgraded and didn't notice your backups
>> broke" kernel.
>>
> 
>  Can you give examples of backup solutions that rely on atime being updated?
> I can understand backup tools using mtime/ctime for incremental backups (like 
> tar + Amanda, etc), but I'm having trouble figuring out why someone would 
> want to use atime for that.
> 
Programs which migrate unused files or delete them are the usual cases.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
