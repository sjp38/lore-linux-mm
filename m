Date: Tue, 20 May 2008 18:23:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] memcg: documentation for controll file
Message-Id: <20080520182338.a7614fc0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48329421.8080904@openvz.org>
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
	<48329421.8080904@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008 13:04:33 +0400
Pavel Emelyanov <xemul@openvz.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Add a documentation for memory resource controller's files.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I have described some files, that should be created by a control group,
> which uses a res_counter in Documentation/controllers/resource_counter.txt
> section 4.
> 
Ah, sorry. I missed it.

> Maybe it's worth adding a reference to this file, or even rework this
> text? How do you think?
> 
I'll drop parameters from res_coutner and just shows special files for
memory controller and some how-to-use text. (maybe add to memory.txt)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
