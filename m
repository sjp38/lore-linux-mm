From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free maps
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <fa.n04s9ar.17sg3f@ifi.uio.no>
	<E1ChwhG-00011c-00@be1.7eggert.dyndns.org>
Date: Mon, 27 Dec 2004 00:02:33 +0100
In-Reply-To: <E1ChwhG-00011c-00@be1.7eggert.dyndns.org> (Bodo Eggert's message
	of "Fri, 24 Dec 2004 22:10:02 +0100")
Message-ID: <87wtv464ty.fsf@deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 7eggert@gmx.de
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Bodo Eggert:

> Christoph Lameter wrote:
>
>> o Add scrub daemon
>
> Please use names a simple user may understand.
>
> What about memcleand or zeropaged instead?

But overwritting with zeros is commonly called "scrubbing", as in
"password scrubbing".
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
