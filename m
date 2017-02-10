Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7766B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:34:59 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v184so42729277pgv.6
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:34:59 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b84si1294626pfl.88.2017.02.10.02.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 02:34:58 -0800 (PST)
Date: Fri, 10 Feb 2017 11:34:56 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170210103456.GA16086@kroah.com>
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz>
 <20170209200737.GB11098@kroah.com>
 <20170209205407.GF31906@dhcp22.suse.cz>
 <845d420f-dd26-fb48-c8ef-10ca1995daf8@sonymobile.com>
 <20170210075149.GA17166@kroah.com>
 <b6236b07-3fbd-4f58-f7bb-97847ec8ad7f@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b6236b07-3fbd-4f58-f7bb-97847ec8ad7f@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Riley Andrews <riandrews@android.com>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Feb 10, 2017 at 10:05:12AM +0100, peter enderborg wrote:
> On 02/10/2017 08:51 AM, Greg Kroah-Hartman wrote:
> > On Fri, Feb 10, 2017 at 08:21:32AM +0100, peter enderborg wrote:
> >> Im not speaking for google, but I think there is a work ongoing to
> >> replace this with user-space code.
> > Really?  I have not heard this at all, any pointers to whom in Google is
> > doing it?
> >
> I think it was mention some of the google conferences. The idea
> is the lmkd that uses memory pressure events to trigger this.
> From git log in lmkd i think Colin Cross is involved.

Great, care to add him to this thread?

> >> Until then we have to polish this version as good as we can. It is
> >> essential for android as it is now.
> > But if no one is willing to do the work to fix the reported issues, why
> > should it remain? 
> It is needed by billions of phones.

Well, something is needed, not necessarily this solution :)

> >  Can you do the work here? 
> No. Change the kernel is only one small part of the solution.

Why can't you work on the whole thing?

> >  You're already working on
> > fixing some of the issues in a differnt way, why not do the "real work"
> > here instead for everyone to benifit from?
> The long term solution is something from AOSP.  As you know
> we tried to contribute this to AOSP.  As OEM we can't turn android
> upside down.  It has to be a step by step.

I posted in AOSP that you should post the patches here as AOSP shouldn't
be taking patches that the community rejects.  There's no reason you
can't also provide the "fix the userspace side" patches into AOSP at the
same time, and provide the "correct" solution here as well.  The kernel
community doesn't care abotu AOSP, nor should anyone expect it to.  You
are going to have to work across both boundries/communities in order to
resolve this properly.

If not, as the kernel developers have pointed out, the in-kernel stuff
will probably be removed as it's causing problems for the upstream
developers, and no one is stepping up to fix it "correctly".

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
