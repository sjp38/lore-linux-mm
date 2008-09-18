Message-ID: <48D2C8DD.4040303@linux-foundation.org>
Date: Thu, 18 Sep 2008 16:32:13 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D1625C.7000309@redhat.com>	 <48D17A93.4000803@goop.org> <48D29AFB.5070409@linux-foundation.org>	 <48D2A392.6010308@goop.org>	 <33307c790809181352h14f2cf26kc73de75b939177b5@mail.gmail.com>	 <48D2BFB8.6010503@redhat.com>	 <33307c790809181411j41a6fc4ev8560a13ed8661ec2@mail.gmail.com>	 <48D2C46A.5030702@linux-foundation.org> <33307c790809181421k52ed6a36h9d4ee40d5799a536@mail.gmail.com>
In-Reply-To: <33307c790809181421k52ed6a36h9d4ee40d5799a536@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Chris Snook <csnook@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Martin Bligh wrote:

>> Well, I guess we need a new binary format that allows one to execute binaries
>> in kernel address space with full powers.
> 
> Seems ... extreme ;-)

Well yes ....

> Maybe we just do it if we're in readahead? (or similar)

If we are in kernel space then the binary can call the readahead function as
needed ... ;-O

Ok, seriously: Anonymous pages are not subject to readahead so it wont work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
