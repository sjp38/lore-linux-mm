From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14190.31634.420888.788269@dukat.scot.redhat.com>
Date: Mon, 21 Jun 1999 18:51:14 +0100 (BST)
Subject: Re: [RFC] [RFT] [PATCH] kanoj-mm9-2.2.10 simplify swapcache/shm code interaction
In-Reply-To: <199906211717.KAA67065@google.engr.sgi.com>
References: <14190.16136.552955.557245@dukat.scot.redhat.com>
	<199906211717.KAA67065@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, torvalds@transmeta.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 21 Jun 1999 10:17:10 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> Okay, wrong choice of name on the parameter "shmfs". Would it help
> to think of the new last parameter to rw_swap_page_base as "dolock",
> which the caller has to pass in to indicate whether there is a 
> swap lock map bit?

Maybe, but I still don't see what it buys.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
