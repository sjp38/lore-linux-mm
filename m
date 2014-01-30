Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id B9AB56B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:17:31 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so3680087pbc.2
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:17:31 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id s4si8048722pbg.93.2014.01.30.14.17.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 14:17:30 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so3693257pab.4
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 14:17:30 -0800 (PST)
Date: Thu, 30 Jan 2014 14:17:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] Description for memmap in kernel-parameters.txt is wrong
In-Reply-To: <52EAB56E.2030102@infradead.org>
Message-ID: <alpine.DEB.2.02.1401301416030.15271@chino.kir.corp.google.com>
References: <CAOvWMLa334E8CYJLrHy6-0ZXBRneoMf-05v422SQw+dbGRubow@mail.gmail.com> <52EAA714.3080809@infradead.org> <CAOvWMLbs-sP+gJHV_5O6ZbV8eTpEKPVRVR238gFcPQeqhCjT3A@mail.gmail.com> <52EAB56E.2030102@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andiry Xu <andiry@gmail.com>, linux-kernel@vger.kernel.org, Andiry Xu <andiry.xu@gmail.com>, Linux MM <linux-mm@kvack.org>

On Thu, 30 Jan 2014, Randy Dunlap wrote:

> >>> Hi,
> >>>
> >>> In kernel-parameters.txt, there is following description:
> >>>
> >>> memmap=nn[KMG]$ss[KMG]
> >>>                         [KNL,ACPI] Mark specific memory as reserved.
> >>>                         Region of memory to be used, from ss to ss+nn.
> >>
> >> Should be:
> >>                           Region of memory to be reserved, from ss to ss+nn.
> >>
> >> but that doesn't help with the problem that you describe, does it?
> >>
> > 
> > Actually it should be:
> >                              Region of memory to be reserved, from nn to nn+ss.
> > 
> > That is, exchange nn and ss.
> 
> Yes, I understand that that's what you are reporting.  I just haven't yet
> worked out how the code manages to exchange those 2 values.
> 

It doesn't, the documentation is correct as written and could be improved 
by your suggestion of "Region of memory to be reserved, from ss to ss+nn."  
I think Andiry probably is having a problem with his bootloader 
interpreting the '$' incorrectly (or variable expansion if coming from the 
shell) or interpreting the resulting user-defined e820 map incorrectly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
