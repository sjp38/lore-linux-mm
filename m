Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 505296B006A
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 20:51:53 -0500 (EST)
Message-ID: <49752E11.20209@cn.fujitsu.com>
Date: Tue, 20 Jan 2009 09:51:13 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] cgroup:add css_is_populated
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>	 <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>	 <20090116120001.f37e1895.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830901191741j4668f529s97ee6e896b0c011d@mail.gmail.com>
In-Reply-To: <6599ad830901191741j4668f529s97ee6e896b0c011d@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Thu, Jan 15, 2009 at 7:00 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Li-san, If you don't like this, could you give me an idea for
>> "How to check cgroup is fully ready or not" ?
>>
>> BTW, why "we have a half filled direcotory - oh well" is allowed....
> 
> That's pretty much inherited from the original cpusets code. It
> probably should be cleaned up, but unless the system is totally hosed
> it seems pretty unlikely for creation of a few dentries to fail.
> 

Yes, but I can see a potential problem. If we have subsystem foo and bar,
and both of them have a control file with exactly the same name, like
foo.stat & bar.stat. Now we mount them with -o noprefix, and then one
of the stat file will fail to be created, without any warnning or notification
to the user.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
