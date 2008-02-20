Date: Wed, 20 Feb 2008 18:24:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
In-Reply-To: <44c63dc40802200056va847417v1cfc847341bb8cc0@mail.gmail.com>
References: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com> <44c63dc40802200056va847417v1cfc847341bb8cc0@mail.gmail.com>
Message-Id: <20080220181447.6444.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <barrioskmc@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Kim-san

Do you adjust hackbench parameter?
my parameter adjust my test machine(8GB mem),
if unchanged, maybe doesn't works it because lack memory.

> I am a many interested in your patch. so I want to test it with exact
> same method as you did.
> I will test it in embedded environment(ARM 920T, 32M ram) and my
> desktop machine.(Core2Duo 2.2G, 2G ram)

Hm
I don't have embedded test machine.
but I can desktop.
I will test it about weekend.
if you don't mind, could you please send me .config file
and tell me your test kernel version?

Thanks, interesting report.


> I guess this patch won't be efficient in embedded environment.
> Since many embedded board just have one processor and don't have any
> swap device.

reclaim conflict rarely happened on UP.
thus, my patch expect no improvement.

but (of course) I will fix regression.

> So, How do I evaluate following field as you did ?
> 
>  * elapse (what do you mean it ??)
>  * major fault

/usr/bin/time command output that.


>  * max parallel reclaim tasks:
>  *  max consumption time of
>         try_to_free_pages():

sorry, I inserted debug code to my patch at that time.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
