Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA14363
	for <linux-mm@kvack.org>; Thu, 8 Apr 1999 22:51:05 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199904090250.TAA40298@google.engr.sgi.com>
Subject: Re: persistent heap design advice
Date: Thu, 8 Apr 1999 19:50:06 -0700 (PDT)
In-Reply-To: <m1ogkywov1.fsf@flinx.ccr.net> from "Eric W. Biederman" at Apr 8, 99 08:42:58 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: kmorgan@inter-tax.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> >>>>> "KM" == Keith Morgan <kmorgan@inter-tax.com> writes:
> 
> KM> I am interested in creating a persistent heap library and would
> KM> appreciate any suggestions on how to proceed. The 'persistent heap'
> KM> would be a region of virtual memory backed by a file and could be
> KM> expanded or contracted.
> 
> KM> In order to build my 'persistent heap' it seems like I need a
> KM> fundamental facility that isn't provided by Linux. Please correct me if
> KM> I'm wrong! It would be something like mmap() ... but different. The
> KM> facility call it phmap for starters) would:
> 
> What do you see missing??
> You obviously need a allactor built on top of your mmaped file but
> besides that I don't see anything missing.
> 
> KM> -map virtual addresses to a user-specified file
> mmap MAP_SHARED

And just be careful not to use the same file mmap'ed MAP_SHARED between
"unrelated" processes ...

> 
> KM> -coordinate the expansion/contraction of the file and the virtual
> KM> address space
> ftruncate, mmap, munmap

mremap might also come in handy, depending on how you want to handle
out-of-boundary requests ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
