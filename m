Message-ID: <20000927182028.B14797@saw.sw.com.sg>
Date: Wed, 27 Sep 2000 18:20:28 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: the new VMt
References: <20000925192453.R2615@redhat.com> <20000925123456.A16612@hq.fsmlabs.com> <20000925202549.V2615@redhat.com> <20000925140419.A18243@hq.fsmlabs.com> <20000925171411.A2397@codepoet.org> <20000926091744.A25214@hq.fsmlabs.com> <20000926170406.C1343@redhat.com> <20000926110247.A4698@codepoet.org> <20000926180820.E1343@redhat.com> <20000926114501.B4780@codepoet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000926114501.B4780@codepoet.org>; from "Erik Andersen" on Tue, Sep 26, 2000 at 11:45:02AM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erik Andersen <andersen@codepoet.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, yodaiken@fsmlabs.com, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 11:45:02AM -0600, Erik Andersen wrote:
[snip]
> "Overcommit" to me is the same things as Mark Hemment stated earlier in this
> thread -- the "fact that the system has over committed its memory resources.
> ie. it has sold too many tickets for the number of seats in the plane, and all
> the passengers have turned up."   Basically any case where too many tickets
> have been sold (applied to the entire system, and all subsystems).
[snip]
> If the Beancounter patch lets the kernel count "passengers", classify them
> (with user hinting) so the pilot and flight attendants (init, X, or whatever)
> always stay on the plane, and has some sane predictable mechanism for booting
> non-priveledged passengers, then I am all for it.  

That's exactly what I'm doing.

> How does one provide the kernel with hints as to which processes are sacred?
> Where does one find this beancounter patch?   How much weight does it add to
> the kernel? 

ftp://ftp.sw.com.sg/pub/Linux/people/saw/kernel/user_beancounter/UserBeancounter.html

The current version has some drawbacks, and one of them is the performance.
Memory accounting is implemented as a kernel thread which goes through page
tables of processes (similar to kswapd), and it appears to consume 1-5% of
CPU (depending on number of processes).  I consider it unacceptable, and have
started reimplementation of the process memory accounting from the beginning.

Best regards
		Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
