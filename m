Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id DD7426B0069
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 09:59:13 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so5607469qaq.24
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 06:59:13 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id x2si22785035qai.74.2014.06.23.06.59.12
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 06:59:13 -0700 (PDT)
Date: Mon, 23 Jun 2014 08:59:10 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH RESEND] slub: return correct error on slab_sysfs_init
In-Reply-To: <53A5471E.50503@oracle.com>
Message-ID: <alpine.DEB.2.11.1406230857010.8409@gentwo.org>
References: <53A0EB84.7030308@oracle.com> <alpine.DEB.2.02.1406181314290.10339@chino.kir.corp.google.com> <alpine.DEB.2.11.1406190939030.2785@gentwo.org> <20140619133201.7f84ae4acbc1b9d8f65e2b4f@linux-foundation.org> <53A43C54.3090402@oracle.com>
 <alpine.DEB.2.02.1406201526190.16090@chino.kir.corp.google.com> <53A5471E.50503@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, akpm@linuxfoundation.org, Greg KH <gregkh@linuxfoundation.org>

On Sat, 21 Jun 2014, Jeff Liu wrote:

> >>
> >
> > Bullshit.  Read the above.
>   ^^^^^^^
> I assume that you spoke like that because I have not reply to you in time, I can
> understand if so.  Otherwise, don't talk to me like that no matter who you are!


Ignore his BS. You already posted the patches that did what he asked for.
Lets go back to that one. I am reversing my reversal. Sorry about that.

> > If you want to return PTR_ERR() when this fails and fixup all the callers,
> > then propose that patch.  Until then, it's a pretty simple rule: if you
> > don't have an errno, don't assume the reason for failure.
>
> As I mentioned previously, Greg don't like to fixup kobjects API via PTR_ERR().
> For me, I neither want to propose PTR_ERR to kobject nor try to push the current
> slub fix, because it's make no sense to slub with either errno.

Lets ignore Greg's incorrect assessment and do what Andrew suggested. I
prefer to have clean error code passing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
