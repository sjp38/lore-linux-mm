Received: by ug-out-1314.google.com with SMTP id s2so419161uge
        for <linux-mm@kvack.org>; Sat, 17 Feb 2007 05:25:07 -0800 (PST)
Message-ID: <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
Date: Sat, 17 Feb 2007 08:25:07 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
In-Reply-To: <1171715652.5186.7.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/17/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Sat, 2007-02-17 at 11:42 +0100, Jaya Kumar wrote:
> > Hi James, Geert, lkml and mm,
>
> Hi Jaya,
>
> > This patch adds support for the Hecuba/E-Ink display with deferred IO.
> > The changes from the previous version are to switch to using a mutex
> > and lock_page. I welcome your feedback and advice.
>
> This changelog ought to be a little more extensive; esp. because you're
> using these fancy new functions ->page_mkwrite() and page_mkclean() in a
> novel way.

Hi Peter,

I had put the comment explaining the usage of mkwrite/mkclean in the
.c file. Oh, I see, in the changelog message. Ok, I'll update with a
changelog message mentioning mkwrite/mkclean.

>
> Also, I'd still like to see a way to call msync() on the mmap'ed region
> to force a flush. I think providing a fb_fsync() method in fbmem.c and a
> hook down to the driver ought to work.

I'm hoping fbdev folk will give feedback if this is okay. James,
Geert, what do you think?

>
> Also, you now seem to use a fixed 1 second delay, perhaps provide an
> ioctl or something to customize this?

Ok. Will do.

>
> And, as Andrew suggested last time around, could you perhaps push this
> fancy new idea into the FB layer so that more drivers can make us of it?

I would like to do that very much. I have some ideas how it could work
for devices that support clean partial updates by tracking touched
pages. But I wonder if it is too early to try to abstract this out.
James, Geert, what do you think?

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
