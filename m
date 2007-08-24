Received: by py-out-1112.google.com with SMTP id f31so2348064pyh
        for <linux-mm@kvack.org>; Thu, 23 Aug 2007 22:27:37 -0700 (PDT)
Message-ID: <bd9320b30708232227v1b297a42pd9b20e04aef758d7@mail.gmail.com>
Date: Thu, 23 Aug 2007 22:27:36 -0700
From: mike <mike503@gmail.com>
Subject: Re: Drop caches - is this safe behavior?
In-Reply-To: <46CE69DE.9040807@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com>
	 <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>
	 <46CE3617.6000708@redhat.com>
	 <1187930857.6406.12.camel@norville.austin.ibm.com>
	 <46CE69DE.9040807@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/23/07, Chris Snook <csnook@redhat.com> wrote:
> Mike --
>
>        Try Dave's suggestion to increase vm.vfs_cache_pressure.  drop_pages
> should never be needed, regardless of which caches you're dropping.
>
>        -- Chris
>

thanks all. i will try it on one of the machines and see how it performs.

this is an opteron 1.8ghz (amd64), ubuntu, latest stable linux kernel,
3 gigs of ram (just FYI) - SATA disk.

i thought i'd do it every 5 minutes not because of a horrible memory
leak that fast, but figured "why not just free up all RAM as often as
possible"

when you said "sar" are you talking about this:

atsar - system activity reporter
Description: system activity reporter
 Monitor system resources such as CPU, network, memory & disk I/O, and
 record data for later analysis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
