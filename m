Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
References: <200002252308.PAA76871@google.engr.sgi.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 29 Feb 2000 11:54:36 +0100
In-Reply-To: kanoj@google.engr.sgi.com's message of "Fri, 25 Feb 2000 15:08:49 -0800 (PST)"
Message-ID: <qwwem9wnus3.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi Kanoj,


kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:
> This is a patch against 2.3.47 that tries to implement shared /dev/zero
> mappings. This is just a first cut attempt, I am hoping I will find a
> few people to apply the patch and throw some real life programs at it
> (preferably on low memory machines so that swapping is induced). 
> 
> Currently, you will also need to turn on CONFIG_SYSVIPC, but most of
> the shm.c code can be split into a new ipc/shm_core.c file that is
> always compiled in, irrespective of CONFIG_SYSVIPC. Linus, do you 
> think this is the proper direction to follow?
> 
> Thanks. Comments and feedback welcome ...

Why do you use this special zero_id stuff? It clutters up the whole
code.

If you would simply open a normal shm segment with key IPC_PRIVATE and
directly remove it nobody can attach to it and it will be released on
exit and everything. No special handling needed any more. BTW that's
exectly what we do in user space to circumvent the missing MAP_ANON |
MAP_SHARED.

I would also prefer to be able to see the allocated segments with the
ipc* commands.

Greetings
          Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
