Date: Tue, 26 Sep 2000 11:45:02 -0600
From: Erik Andersen <andersen@codepoet.org>
Subject: Re: the new VMt
Message-ID: <20000926114501.B4780@codepoet.org>
Reply-To: andersen@codepoet.org
References: <20000925121315.A15966@hq.fsmlabs.com> <20000925192453.R2615@redhat.com> <20000925123456.A16612@hq.fsmlabs.com> <20000925202549.V2615@redhat.com> <20000925140419.A18243@hq.fsmlabs.com> <20000925171411.A2397@codepoet.org> <20000926091744.A25214@hq.fsmlabs.com> <20000926170406.C1343@redhat.com> <20000926110247.A4698@codepoet.org> <20000926180820.E1343@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000926180820.E1343@redhat.com>; from sct@redhat.com on Tue, Sep 26, 2000 at 06:08:20PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: yodaiken@fsmlabs.com, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue Sep 26, 2000 at 06:08:20PM +0100, Stephen C. Tweedie wrote:
> Hi,
> 
> On Tue, Sep 26, 2000 at 11:02:48AM -0600, Erik Andersen wrote:
> 
> > Another approach would be to let user space turn off overcommit.  
> 
> No.  Overcommit only applies to pageable memory.  Beancounter is
> really needed for non-pageable resources such as page tables and
> mlock()ed pages.

I think we do agree here, though we are having problems with semantics.

"Overcommit" to me is the same things as Mark Hemment stated earlier in this
thread -- the "fact that the system has over committed its memory resources.
ie. it has sold too many tickets for the number of seats in the plane, and all
the passengers have turned up."   Basically any case where too many tickets
have been sold (applied to the entire system, and all subsystems).

To extend the airplane metaphor a bit past credibility...

When an airline sells too many tickets, it bribes people to get off the plane.
For the kernel, it tends to fall over, or starts kicking off pilots and flight
attendants.

If the Beancounter patch lets the kernel count "passengers", classify them
(with user hinting) so the pilot and flight attendants (init, X, or whatever)
always stay on the plane, and has some sane predictable mechanism for booting
non-priveledged passengers, then I am all for it.  

How does one provide the kernel with hints as to which processes are sacred?
Where does one find this beancounter patch?   How much weight does it add to
the kernel? 

 -Erik

--
Erik B. Andersen   email:  andersee@debian.org
--This message was written using 73% post-consumer electrons--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
