Received: by py-out-1112.google.com with SMTP id f47so2830723pye.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2008 02:55:39 -0800 (PST)
Message-ID: <2f11576a0802210255k1e3acad7n87814e916fd24509@mail.gmail.com>
Date: Thu, 21 Feb 2008 19:55:39 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
In-Reply-To: <44c63dc40802210138s100e921ekde01b30bae13beb1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220181447.6444.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40802200149r6b03d970g2fbde74b85ad5443@mail.gmail.com>
	 <20080220185648.6447.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40802210138s100e921ekde01b30bae13beb1@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <barrioskmc@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Kim-san,

Thank you very much.
btw, what different between <test 1> and <test 2>?

>  It was a very interesting result.
>  In embedded system, your patch improve performance a little in case
>  without noswap(normal case in embedded system).
>  But, more important thing is OOM occured when I made 240 process
>  without swap device and vanilla kernel.
>  Then, I applied your patch, it worked very well without OOM.

Wow, it is very interesting result!
I am very happy.

>  I think that's why zone's page_scanned was six times greater than
>  number of lru pages.
>  At result, OOM happened.

please repost question with change subject.
i don't know reason of vanilla kernel behavior, sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
