Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B34A16B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 12:33:44 -0500 (EST)
Message-ID: <4EC2A274.8080801@goop.org>
Date: Tue, 15 Nov 2011 09:33:40 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default> <75efb251-7a5e-4aca-91e2-f85627090363@default> <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy> <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com> <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com> <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default> <20111031223717.GI3466@redhat.com> <1b2e4f74-7058-4712-85a7-84198723e3ee@default 4EB1AD53.2000600@redhat.com> <cb397723-5297-493d-9bbd-522a6400a5a6@default> <4EC29367.9040106@redhat.com>
In-Reply-To: <4EC29367.9040106@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On 11/15/2011 08:29 AM, Rik van Riel wrote:
> On 11/02/2011 05:14 PM, Dan Magenheimer wrote:
>
>> It occurs to me that batching could be done locally without
>> changing the in-kernel "API" (i.e. frontswap_ops)... the
>> guest-side KVM tmem-backend-driver could do the compression
>> into guest-side memory and make a single
>> hypercall=vmexit/vmenter whenever it has collected enough for
>> a batch.
>
> That seems like the best way to do it, indeed.
>
> Do the current hooks allow that mode of operation,
> or do the hooks only return after the entire operation
> has completed?

The APIs are synchronous, but need only return once the memory has been
dealt with in some way.  If you were batching before making a hypercall,
then the implementation would just have to make a copy into its private
memory and you'd have to make sure that lookups on batched but
unsubmitted pages work.

(It's been a while since I've looked at these patches, but I'm assuming
nothing fundamental has changed about them lately.)

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
