Date: Tue, 12 Sep 2000 11:24:38 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] workaround for lost dirty bits on x86 SMP
Message-ID: <20000912112438.C28418@redhat.com>
References: <200009120059.RAA78304@google.engr.sgi.com> <Pine.LNX.3.96.1000911210010.7937B-100000@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.3.96.1000911210010.7937B-100000@kanga.kvack.org>; from bcrl@redhat.com on Mon, Sep 11, 2000 at 09:36:35PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bcrl@redhat.com
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 11, 2000 at 09:36:35PM -0400, bcrl@redhat.com wrote:

> Fwiw, with the patch, running a make -j bzImage on a 4 way box does not
> seem to have made a difference.

Of course it won't, because you aren't testing the new behaviour!
Anonymous pages are always dirty, and shared mmaped pages in
MAP_PRIVATE regions are always clean.  The only place where you need
to track the dirty bit dynamically is when you use shared writeable
mmaps --- can you measure a performance change there?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
