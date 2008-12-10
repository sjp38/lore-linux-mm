Message-ID: <493F151B.50800@cn.fujitsu.com>
Date: Wed, 10 Dec 2008 09:02:19 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/6] memcg: Documentation for internal implementation
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>	<20081209200413.d842ede4.kamezawa.hiroyu@jp.fujitsu.com> <20081210092735.25d9d618.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081210092735.25d9d618.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Paul, Balbir
> 
> I have a question.
> 
> Why cgroup's documentation directroy is divided into 2 places ?
> 
> 	Documentation/cgroups
> 	             /controllers
> 

Documentation/cgroups was created by Matt Helsley, when he added freezer-subsystem.txt,
and he also moved cgroups.txt to the new Documentation/cgroups.

> If no strong demands, I'd like to remove "controllers" directroy and move

I prepared a patch to do so long ago, but didn't ever send it out.

> contents under "cgroups". Some people complains me that finding document
> for memcg is not easy.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
