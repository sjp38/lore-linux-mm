Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 047388D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 17:35:21 -0500 (EST)
Received: by iwc10 with SMTP id 10so5257616iwc.14
        for <linux-mm@kvack.org>; Mon, 07 Feb 2011 14:35:20 -0800 (PST)
Subject: Re: [RFC] Split up mm/bootmem.c
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <AANLkTim2GcBMMMr0tABf=3GwHX8oX05-Dn8tdZbYpt_b@mail.gmail.com>
References: <1297092614-1906-1-git-send-email-namhyung@gmail.com>
	 <AANLkTim2GcBMMMr0tABf=3GwHX8oX05-Dn8tdZbYpt_b@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Feb 2011 07:35:13 +0900
Message-ID: <1297118113.1808.2.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011-02-07 (i??), 10:45 -0800, Yinghai Lu:
> On Mon, Feb 7, 2011 at 7:30 AM, Namhyung Kim <namhyung@gmail.com> wrote:
> > The bootmem code contained many #ifdefs in it so that it could be
> > splitted into two files for the readability. The split was quite
> > mechanical and only function need to be shared was free_bootmem_late.
> >
> > Tested on x86-64 and um which use nobootmem and bootmem respectively.
> >
> > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> 
> 
> https://lkml.org/lkml/2010/6/16/44
> ...
> 

Ah, you already made same patch before. OK, I'll drop mine then.
Thanks.


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
