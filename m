Date: Wed, 16 Jan 2008 10:48:55 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/5] memory_pressure_notify() caller
In-Reply-To: <cfd9edbf0801151539g72ca9777h7ac43a31aadc730e@mail.gmail.com>
References: <20080115175925.215471e1@bree.surriel.com> <cfd9edbf0801151539g72ca9777h7ac43a31aadc730e@mail.gmail.com>
Message-Id: <20080116104536.11AE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-2022-JP?B?IkRhbmllbCBTcBskQmlPGyhCZyI=?= <daniel.spang@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Daniel

> > > The notification fires after only ~100 MB allocated, i.e., when page
> > > reclaim is beginning to nag from page cache. Isn't this a bit early?
> > > Repeating the test with swap enabled results in a notification after
> > > ~600 MB allocated, which is more reasonable and just before the system
> > > starts to swap.
> >
> > Your issue may have more to do with the fact that the
> > highmem zone is 128MB in size and some balancing issues
> > between __alloc_pages and try_to_free_pages.
> 
> I don't think so. I ran the test again without highmem and noticed the
> same behaviour:

Thank you for good point out!
Could you please post your test program and reproduced method?

unfortunately,
my simple test is so good works in swapless system ;-)

thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
