Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id B0D3F6B00D7
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 08:17:17 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id q5so9359428wiv.10
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 05:17:17 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id pv8si454074wjc.98.2014.11.04.05.17.16
        for <linux-mm@kvack.org>;
        Tue, 04 Nov 2014 05:17:16 -0800 (PST)
Date: Tue, 4 Nov 2014 15:13:56 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Why page fault handler behaved this way? Please help!
Message-ID: <20141104131356.GC28274@node.dhcp.inet.fi>
References: <771b3575.1fa3f.1495fe48476.Coremail.michaelbest002@126.com>
 <CAGdaadaxRn8yB3jWUKvyosnjHm133n5BnFX8rsaVm9-7Q+M1ZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAGdaadaxRn8yB3jWUKvyosnjHm133n5BnFX8rsaVm9-7Q+M1ZA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Cc: =?utf-8?B?56em5byL5oiI?= <michaelbest002@126.com>, kernelnewbies <kernelnewbies@kernelnewbies.org>, linux-mm <linux-mm@kvack.org>

On Tue, Nov 04, 2014 at 07:41:08PM +0700, Mulyadi Santosa wrote:
> Hello...
> 
> how big is your binary anyway?
> 
> from your log, if my calculation is right, your code segment is around 330
> KiB. But bear in mind, that not all of them are your code. There are other
> code like PLT, function prefix and so on.
> 
> Also, even if your code is big, are you sure all of them are executed?
> Following 20/80 principle, most of the time, when running an application,
> only 20% portion of the application are really used/executed during 80% of
> application lifetime. The rest, it might untouched at all.
> 
> 
> On Thu, Oct 30, 2014 at 2:10 PM, c?|a 1/4 ?ae?? <michaelbest002@126.com> wrote:
> 
> >
> >
> >
> > Dear all,
> >
> >
> > I am a kernel newbie who want's to learn more about memory management.
> > Recently I'm doing some experiment on page fault handler. There happened
> > something that I couldn't understand.
> >
> >
> > From reading the book Understanding the Linux Kernel, I know that the
> > kernel loads a page as late as possible. It's only happened when the
> > program has to reference  (read, write, or execute) a page yet the page is
> > not in memory.
> >
> >
> > However, when I traced all page faults in my test program, I found
> > something strange. My test program is large enough, but there are only two
> > page faults triggered in the code segment of the program, while most of the
> > faults are not in code segment.
> >
> >
> > At first I thought that perhaps the page is not the normal 4K page. Thus I
> > turned off the PAE support in the config file. But the log remains
> > unchanged.
> >
> >
> > So why are there only 2 page faults in code segment? It shouldn't be like
> > this in my opinion. Please help me.

We have "faultaround" feature in recent kernel which tries to map 64k with
one page fault if the pages are already in page cache. There's handle in
debugfs to disable the feature, if you want to play with this.

> > The attachment is my kernel log. Limited by the mail size, I couldn't
> > upload my program, but I believe that the log is clear enough.
> >
> >
> > Thank you very much.
> > Best regards
> >
> >
> > _______________________________________________
> > Kernelnewbies mailing list
> > Kernelnewbies@kernelnewbies.org
> > http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies
> >
> >
> 
> 
> -- 
> regards,
> 
> Mulyadi Santosa
> Freelance Linux trainer and consultant
> 
> blog: the-hydra.blogspot.com
> training: mulyaditraining.blogspot.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
