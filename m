Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m9LDPin9029140
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 18:55:44 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9LDPipu1052800
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 18:55:44 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m9LDPgeq027862
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 18:55:44 +0530
Message-ID: <48FDD854.8020901@linux.vnet.ibm.com>
Date: Tue, 21 Oct 2008 18:55:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
References: <20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com> <48FD82E3.9050502@cn.fujitsu.com> <20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com> <48FD943D.5090709@cn.fujitsu.com> <20081021175735.0c3d3534.kamezawa.hiroyu@jp.fujitsu.com> <48FD9D30.2030500@cn.fujitsu.com> <20081021182551.0158a47b.kamezawa.hiroyu@jp.fujitsu.com> <48FDA6D4.3090809@cn.fujitsu.com> <20081021191417.02ab97cc.kamezawa.hiroyu@jp.fujitsu.com> <48FDB584.7080608@cn.fujitsu.com> <20081021111951.GB4476@elte.hu> <20081021202325.938678c0.kamezawa.hiroyu@jp.fujitsu.com> <48FDBD18.6090100@linux.vnet.ibm.com> <20081021210015.02c8cacc.kamezawa.hiroyu@jp.fujitsu.com> <48FDC7B0.6040704@linux.vnet.ibm.com> <20081021220927.97df17fa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021220927.97df17fa.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Oct 2008 17:44:40 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> I got an idea and maybe can send a patch soon. I'm now finding x86-32 box..
>> Please send it to me, I am able to reproduce the problem with my kvm setup on my
>> 32 bit system. I can do a quick test/verification for you.
>>
> Thanks. how about this ? test on x86-64 is done.
> -Kame
> ==

OK, I'll test it, believe it or not, I was trying a similar patch, although not
as comprehensive.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
