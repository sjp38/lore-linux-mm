Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] slabasap-mm5_A2
Date: Mon, 9 Sep 2002 18:28:18 -0400
References: <200209071006.18869.tomlins@cam.org> <200209091733.44112.tomlins@cam.org> <3D7D1B94.16F220E3@digeo.com>
In-Reply-To: <3D7D1B94.16F220E3@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209091828.18614.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On September 9, 2002 06:07 pm, Andrew Morton wrote:
> Ed Tomlinson wrote:
> > Hi Andrew,
> >
> > Found three oops when checking this afternoon's log.  Looks like
> > *total_scanned can be zero...
> >
> > how about;
> >
> > ratio = pages > *total_scanned ? pages / (*total_scanned | 1) : 1;
>
> Yup, thanks.  I went the "+ 1" route ;)

I used the above to catch two situations.  One was if 

                to_reclaim = zone->pages_high - zone->free_pages;
                if (to_reclaim < 0)
                        continue;       /* zone has enough memory */

triggered an left *total_scanned zero, and second if to catch the case
when pages > *total_scanned.  Think both might happen.  In the oops,
think *total_scanned was zero.

Ed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
