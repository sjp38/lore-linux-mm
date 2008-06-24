Received: by rv-out-0708.google.com with SMTP id f25so10916080rvb.26
        for <linux-mm@kvack.org>; Tue, 24 Jun 2008 11:19:29 -0700 (PDT)
Message-ID: <2f11576a0806241119h64c46b0dt251980056fc94353@mail.gmail.com>
Date: Wed, 25 Jun 2008 03:19:29 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] fix to putback_lru_page()/unevictable page handling rework v3
In-Reply-To: <1214329708.6563.43.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080621185408.E832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080624184122.D838.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1214327987.6563.22.camel@lts-notebook>
	 <2f11576a0806241035p45a440e1gb798091ef39cffc8@mail.gmail.com>
	 <1214329708.6563.43.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

>> but I still happend panic on usex and nishimura-san's cpuset migration test.
>>   -> http://marc.info/?l=linux-mm&m=121375647720110&w=2
>
> I saw the description of the cpuset migration test.  Have you wrapped
> this in a script suitable for running under usex?

Ah, no. sorry.
I use multiple console by cpuset test and usex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
