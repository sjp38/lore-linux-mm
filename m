From: David Lang <david.lang@digitalinsight.com>
Date: Fri, 24 Jan 2003 11:14:50 -0800 (PST)
Subject: Re: your mail
In-Reply-To: <57047.210.212.228.78.1043401756.webmail@mail.nitc.ac.in>
Message-ID: <Pine.LNX.4.44.0301241110470.10187-100000@dlang.diginsite.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Anoop J." <cs99001@nitc.ac.in>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

the cache never sees the virtual addresses, it operated excclusivly on the
physical addresses so the problem of aliasing never comes up.

virtual to physical addres mapping is all resolved before anything hits
the cache.

David Lang

On Fri, 24 Jan 2003, Anoop J. wrote:

> Date: Fri, 24 Jan 2003 15:19:16 +0530 (IST)
> From: Anoop J. <cs99001@nitc.ac.in>
> To: david.lang@digitalinsight.com
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
> Subject: Re: your mail
>
> ok i shall put it in another way
> since virtual indexing is a representation of the virtual memory,
> it is possible for more multiple virtual addresses to represent the same
> physical address.So the problem of aliasing occurs in the cache.Does page
> coloring guarantee a unique mapping of physical address.If so how is the
> maping from virtual to physical address
>
>
>
> Thanks
>
>
>
> > I think this is a case of the same tuerm being used for two different
> > purposes. I don't know the use you are refering to.
> >
> > David Lang
> >
> >
> >
>
>
>
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
