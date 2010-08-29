Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 90B8E6B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 11:42:29 -0400 (EDT)
Received: by pwj6 with SMTP id 6so1972390pwj.14
        for <linux-mm@kvack.org>; Sun, 29 Aug 2010 08:42:28 -0700 (PDT)
Date: Mon, 30 Aug 2010 00:42:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: fix missing place to check nr_swap_pages.
Message-ID: <20100829154221.GB2714@barrios-desktop>
References: <1282867897-31201-1-git-send-email-yinghan@google.com>
 <AANLkTimaLBJa9hmufqQy3jk7GD-mJDbg=Dqkaja0nOMk@mail.gmail.com>
 <AANLkTi=xUMSZ7wX-2BtJ0-+2BYLCTW=VPTAErinb5Zd2@mail.gmail.com>
 <AANLkTinP_q7S4_O921hdBoedmTp-7gw0+=4DPHZGmysi@mail.gmail.com>
 <AANLkTin6+nHOowdptW2jaxg9urn3OLf9ArgGzKjWnQLM@mail.gmail.com>
 <AANLkTin92hywGThE=Z7=ZJOJrmw4yA-d-sFCnUYxS2hd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTin92hywGThE=Z7=ZJOJrmw4yA-d-sFCnUYxS2hd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Venkatesh Pallipadi <venki@google.com>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 06:30:58PM -0700, Venkatesh Pallipadi wrote:
> On Fri, Aug 27, 2010 at 9:35 AM, Ying Han <yinghan@google.com> wrote:
> > In our system, we do have swap configured. In vmscan.c, there are
> > couple of places where we skip scanning
> > and shrinking anon lru while the condition if(nr_swap_pages <= 0)  is
> > true. It still make sense to me to add it
> > to the shrink_active() condition as the initial patch.
> >
> > Also, we found it is quite often to hit the condition
> > inactive_anon_is_low on machine with small numa node size, since the
> > zone->inactive_ratio is set based on the zone->present_pages.
> >
> 
> Does "total_swap_pages" help?

Yes. Thanks for advising. 

> 
> Thanks,
> Venki

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
