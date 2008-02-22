Date: Fri, 22 Feb 2008 12:09:58 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller in Kconfig
In-Reply-To: <20080221235527.GD25977@elf.ucw.cz>
References: <2f11576a0802210646u77409690me940717fac746315@mail.gmail.com> <20080221235527.GD25977@elf.ucw.cz>
Message-Id: <20080222120758.AE67.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, Jan Engelhardt <jengelh@computergmbh.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, John Stoffel <john@stoffel.org>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> > I think one reason of many people easy confusion is caused by bad menu
> > hierarchy.
> > I popose mem-cgroup move to child of cgroup and resource counter
> > (= obey denend on).
> 
> > +config CGROUP_MEM_CONT
> > +	bool "Memory controller for cgroups"
> 
> Memory _resource_ controller for cgroups?

Ahhh
my proposal only change menu hierarchy.
I don't know best name and i hope avoid rename discussion ;-)

Thanks.


- kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
