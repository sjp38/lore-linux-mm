From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906291736.KAA20280@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
Date: Tue, 29 Jun 1999 10:36:41 -0700 (PDT)
In-Reply-To: <14200.44196.867290.619751@dukat.scot.redhat.com> from "Stephen C. Tweedie" at Jun 29, 99 12:23:16 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: cel@monkey.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Mon, 28 Jun 1999 15:15:29 -0700 (PDT), kanoj@google.engr.sgi.com
> (Kanoj Sarcar) said:
> 
> >> kswapd itself always uses a gfp_mask that includes GFP_IO, so nothing it
> >> calls will ever wait.  the I/O it schedules is asynchronous, and when
> >> complete, the buffer exit code in end_buffer_io_async will set the page
> >> flags appropriately for shrink_mmap() to come by and steal it. also, the
> >> buffer code will use pre-allocated buffers if gfp fails.
> >> 
> 
> > Which is why you must gurantee that kswapd can always run, and keep
> > as few blocking points as possible ...
> 
> Look, we're just going round in circles here.
> 
> kswapd *can* always run.
>

Not if you are going to try grabbing mmap_sem in that path ... 

Anyway, I guess we have established that is a bad idea ...

Kanoj 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
