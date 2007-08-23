Date: Thu, 23 Aug 2007 08:56:40 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 2.6.20-rc5 1/1] MM: enhance Linux swap subsystem
Message-Id: <20070823085640.f6b43ab3.randy.dunlap@oracle.com>
In-Reply-To: <4df04b840708230247l69d03112lc5b66ff3359eac2@mail.gmail.com>
References: <4df04b840701212309l2a283357jbdaa88794e5208a7@mail.gmail.com>
	<4df04b840701301852i41687edfl1462c4ca3344431c@mail.gmail.com>
	<Pine.LNX.4.64.0701312022340.26857@blonde.wat.veritas.com>
	<4df04b840702122152o64b2d59cy53afcd43bb24cb7a@mail.gmail.com>
	<4df04b840702200106q670ff944k118d218fed17b884@mail.gmail.com>
	<4df04b840702211758t1906083x78fb53b6283349ca@mail.gmail.com>
	<45DCFDBE.50209@redhat.com>
	<4df04b840702221831x76626de1rfa70cb653b12f495@mail.gmail.com>
	<45DE6080.6030904@redhat.com>
	<4df04b840702241747ne903699w636d37b40351b752@mail.gmail.com>
	<4df04b840708230247l69d03112lc5b66ff3359eac2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yunfeng zhang <zyf.zeroos@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2007 17:47:44 +0800 yunfeng zhang wrote:

> Signed-off-by: Yunfeng Zhang <zyf.zeroos@gmail.com>
> 
> The mayor change is
> 1) Using nail arithmetic to maximum SwapDevice performance.
> 2) Add PG_pps bit to sign every pps page.
> 3) Some discussion about NUMA.
> See vm_pps.txt
> 
> Index: linux-2.6.22/Documentation/vm_pps.txt
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6.22/Documentation/vm_pps.txt	2007-08-23 17:04:12.051837322 +0800
> @@ -0,0 +1,365 @@
> +
> +                         Pure Private Page System (pps)
> +                              zyf.zeroos@gmail.com
> +                              December 24-26, 2006
> +                            Revised on Aug 23, 2007
> +
> +// Purpose <([{
> +The file is used to document the idea which is published firstly at
> +http://www.ussg.iu.edu/hypermail/linux/kernel/0607.2/0451.html, as a part of my
> +OS -- main page http://blog.chinaunix.net/u/21764/index.php. In brief, the
> +patch of the document is for enchancing the performance of Linux swap
> +subsystem. You can find the overview of the idea in section <How to Reclaim
> +Pages more Efficiently> and how I patch it into Linux 2.6.21 in section
> +<Pure Private Page System -- pps>.
> +// }])>

Hi,
What (text) format/markup language is the vm_pps.txt file in?

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
