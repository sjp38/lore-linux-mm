Subject: Re: 2.6.25-rc4 OOMs itself dead on bootup (modprobe bug?)
From: Jon Masters <jcm@redhat.com>
In-Reply-To: <1205016884.24056.1.camel@lov.site>
References: <47D02940.1030707@tuxrocks.com> <20080306184954.GA15492@elte.hu>
	 <47D1971A.7070500@tuxrocks.com> <47D23B7E.3020505@tuxrocks.com>
	 <20080308135318.GA8036@auslistsprd01.us.dell.com>
	 <47D29CAB.50301@tuxrocks.com>  <1205013197.5484.81.camel@perihelion>
	 <1205016884.24056.1.camel@lov.site>
Content-Type: text/plain
Date: Sat, 08 Mar 2008 22:41:32 -0500
Message-Id: <1205034092.5484.115.camel@perihelion>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Cc: Frank Sorenson <frank@tuxrocks.com>, Matt Domsch <Matt_Domsch@dell.com>, Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-03-08 at 23:54 +0100, Kay Sievers wrote:
> On Sat, 2008-03-08 at 16:53 -0500, Jon Masters wrote:
> > On Sat, 2008-03-08 at 08:03 -0600, Frank Sorenson wrote:
> > 
> > > It's module-init-tools-3.4-2.fc8.x86_64 (most recent Fedora rpm available).
> > 
> > Ok, so I'll see if I can find a Dell system in the office to reproduce
> > this on Monday. Any Dell should do, right Matt?
> 
> Should not be needed:
>   http://lkml.org/lkml/2008/3/8/91

Oh, all's well that ends well :)

Jon.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
