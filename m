Message-ID: <3DE4BB87.8070708@torque.net>
Date: Wed, 27 Nov 2002 23:33:11 +1100
From: Douglas Gilbert <dougg@torque.net>
Reply-To: dougg@torque.net
MIME-Version: 1.0
Subject: Re: [PATCH] Really start using the page walking API
References: <20021124233449.F5263@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Andrew Morton <akpm@digeo.com>, Kai Makisara <Kai.Makisara@kolumbus.fi>, Gerd Knorr <kraxel@bytesex.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:
> Hi all,
> 
> here come some improvements of the page walking API code.
> 
> First: make_pages_present() would do an infinite recursion, if
>    used in find_extend_vma(). I fixed this. Might as well have
>    caused the ntp crash, that has been observed. 
>    So these make_pages_present parts are really important.
> 
> I also did the promised rewrite of make_pages_present() and its
> users.
> 
> MM-Gurus: Please double check, that I always provide the right vma.
> 
> I also did two sample implementations (Kai and Doug, this is why
> you are CC'ed) of the scatter list walking and removed ~100
> lines of code while doing it.

<snip/>
Ingo,
I see that Andrew has put this patch in 2.5.49-mm2 and seems
to be asking for testers. So I will try and test sg's usage.
[It is a while since I built in sg (and other drivers) but
working modules has been very frustrating since 2.5.48 ...]

Doug Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
