Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id E78F26B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 11:53:22 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id c41so7543960yho.34
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 08:53:22 -0700 (PDT)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id c29si2127609yha.187.2014.09.05.08.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 08:53:22 -0700 (PDT)
Message-ID: <1409931772.28990.197.camel@misato.fc.hp.com>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 05 Sep 2014 09:42:52 -0600
In-Reply-To: <5409D99C.10305@zytor.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
			 <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
			 <20140904201123.GA9116@khazad-dum.debian.net>
	 <5408C9C4.1010705@zytor.com>
			 <20140904231923.GA15320@khazad-dum.debian.net>
			 <CALCETrWxKFtM8FhnHQz--uaHYbiqShE1XLJxMCKN7Rs4SO14eQ@mail.gmail.com>
			 <1409876991.28990.172.camel@misato.fc.hp.com>
			 <CALCETrUhbx4hFRAkHfczLkZBYo0E7tRmdFyO7bqPd5e9JEWcMA@mail.gmail.com>
		 <1409925614.28990.184.camel@misato.fc.hp.com> <5409D197.2060900@zytor.com>
	 <1409930574.28990.192.camel@misato.fc.hp.com> <5409D99C.10305@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Fri, 2014-09-05 at 08:41 -0700, H. Peter Anvin wrote:
> On 09/05/2014 08:22 AM, Toshi Kani wrote:
> > On Fri, 2014-09-05 at 08:07 -0700, H. Peter Anvin wrote:
> >> On 09/05/2014 07:00 AM, Toshi Kani wrote:
> >>>
> >>> That's a fine idea, but as Ingo also suggested, I am going to disable
> >>> this feature on all Pentium 4 models.  That should give us a safety
> >>> margin.  Using slot 4 has a benefit that it keeps the PAT setup
> >>> consistent with Xen.      
> >>>
> >>
> >> Slot 4 is also the maximally problematic one, because it is the one that
> >> might be incorrectly invoked for the page tables themselves.
> > 
> > Good point.  I wonder if Xen folks feel strongly about keeping the PAT
> > setup consistent with the kernel.  If not, we may choose to use slot 6
> > (or 7).
> > 
> 
> Who cares what the Xen folks "feel strongly about"?  If strong feelings
> were a design criterion Xen support would have been pulled from the
> kernel a long, long time ago.
> 
> The important thing is how to design for the situation that we currently
> have to live with.

I see.  Then, I am going to use slot 7 for WT as suggested by Andy.  I
think it is the safest slot as slot 3 is UC and is not currently used.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
