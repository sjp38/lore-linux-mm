Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 031226B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 04:03:23 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5685574iaj.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 01:03:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120430075417.GA8438@lizard>
References: <4F9E39F1.5030600@kernel.org>
	<CAOJsxLE3A3b5HSrRm0NVCBmzv7AAs-RWEiZC1BL=se309+=WTA@mail.gmail.com>
	<20120430075417.GA8438@lizard>
Date: Mon, 30 Apr 2012 11:03:23 +0300
Message-ID: <CAOJsxLHh8bD7hoqG8nkuaib63PC3kCvD6_2U4iBsCz1JLvZ+xQ@mail.gmail.com>
Subject: Re: vmevent: question?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <cbouatmailru@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

Hi Anton,

On Mon, Apr 30, 2012 at 10:54 AM, Anton Vorontsov
<cbouatmailru@gmail.com> wrote:
> It seems to be a pretty nice driver. Speaking of ABI, the only thing
> I personally dislike is VMEVENT_CONFIG_MAX_ATTRS (i.e. fixed-size
> array in vmevent_config)... but I guess it's pretty easy to make
> it variable-sized array... was there any particular reason to make
> the _MAX thing?

It made the implementation simpler but the ABI should support
variable-sized arrays. We can relax the limitation if necessary.

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
