Date: Mon, 27 Mar 2000 11:59:23 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Why ?
In-Reply-To: <CA2568AF.002D39AF.00@d73mta05.au.ibm.com>
Message-ID: <Pine.LNX.3.96.1000327115808.14059A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Mar 2000 pnilesh@in.ibm.com wrote:

> Why the first 0x0 - 0x07ffffff   virtual addresses are not used by any
> process ?

I think it's to help catch NULL pointer dereferences.

> Is that used by the kernel and if yes for what ?

Other than the aforementioned reason, no.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
