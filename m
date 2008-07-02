Date: Thu, 3 Jul 2008 08:57:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] [6/7] res_counter distance to limit
Message-Id: <20080703085741.1cf105b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830807021219u1cc48e9fx4ebbcab7961a7408@mail.gmail.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
	<20080702211510.6f1fe470.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830807021219u1cc48e9fx4ebbcab7961a7408@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jul 2008 12:19:24 -0700
"Paul Menage" <menage@google.com> wrote:

> On Wed, Jul 2, 2008 at 5:15 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > I wonder wheher there is better name rather than "distance"...
> > give me a hint ;)
> 
> How about res_counter_report_spare() and res_counter_charge_and_report_spare() ?
> 
seems better. thank you.

-Kame

> Paul
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
