Subject: Re: VM tuning through fault trace gathering [with actual code]
References: <Pine.LNX.4.21.0106252152580.941-100000@freak.distro.conectiva>
From: John Fremlin <vii@users.sourceforge.net>
Date: 26 Jun 2001 13:54:30 +0100
In-Reply-To: <Pine.LNX.4.21.0106252152580.941-100000@freak.distro.conectiva> (Marcelo Tosatti's message of "Mon, 25 Jun 2001 21:53:33 -0300 (BRT)")
Message-ID: <m2n16vcsft.fsf@boreas.yi.org.>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> On 25 Jun 2001, John Fremlin wrote:
> 
> > 
> > Last year I had the idea of tracing the memory accesses of the system
> > to improve the VM - the traces could be used to test algorithms in
> > userspace. The difficulty is of course making all memory accesses
> > fault without destroying system performance.

[...]

> Linux Trace Toolkit (http://www.opersys.com/LTT) does that. 

I dld the ltt-usenix paper and skim read it. It didn't seem to talk
about page faults much. Where should I look?

-- 

	http://ape.n3.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
