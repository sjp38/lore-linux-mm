Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 506556B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 09:50:59 -0500 (EST)
Subject: Re: [Linux-decnet-user] Proposed removal of DECnet support
 (was:Re: [BUG] 3.2-rc2:BUG kmalloc-8: Redzone overwritten)
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <OF7785CDCC.246C1F8F-ON80257958.004A9A89-80257958.004C103D@LocalDomain>
References: 
	 <OF7785CDCC.246C1F8F-ON80257958.004A9A89-80257958.004C103D@LocalDomain>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Nov 2011 14:52:17 +0000
Message-ID: <1322664737.2755.17.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.gair@tatasteel.com
Cc: Philipp Schafft <lion@lion.leolix.org>, Chrissie Caulfield <ccaulfie@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Linux-DECnet user <linux-decnet-user@lists.sourceforge.net>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, RoarAudio <roaraudio@lists.keep-cool.org>

Hi,

On Wed, 2011-11-30 at 13:52 +0000, mike.gair@tatasteel.com wrote:
> We're using decnet on linux,
> as a way of expanding a control system,
> using DEC PDP11s (actually charon11 emulations).
> 
> So woud be very interested in keeping decnet supported.
> 
> In theory i'd be interested in maintaining it,
> but i'm not sure what amount of work is involved,
> have no experience of kernel, or where to start.
> 
> Any ideas?
> 
> 
So the issue is basically that due to there being nobody currently
maintaining the DECnet stack, it puts a burden on the core network
maintainers when they make cross-protocol changes, as they have to
figure out what impact the changes are likely to have on the DECnet
stack. So its an extra barrier to making cross-protocol code changes.

If there was an active maintainer who could be a source of knowledge
(and the odd patch to help out making those changes) then this issue
would largely go away.

The most important duty of the maintainer is just to watch whats going
on in the core networking development and to contribute the DECnet part
of that. So it would be most likely be more a reviewing of patches and
providing advice role, than one of writing patches (though it could be
that too) and ensuring that the code continues to function correctly by
testing it from time to time.

The ideal maintainer would have an in-depth knowledge of the core Linux
networking stack (socket layer, dst and neigh code), the DECnet specs
and have a good knowledge of C. 

Bearing in mind the low patch volume (almost zero, except for core
stuff), it would probably be one of the subsystems with the least amount
of work to do in maintaining it. So in some ways, a good intro for a new
maintainer.

I do try and keep an eye on what get submitted to the DECnet code and
I'll continue to do that while it is still in the kernel. However, it is
now quite a long time since I last did any substantial work in the
networking area and things have moved on a fair bit in the mean time. I
don't have a lot of time to review DECnet patches these days and no way
to actually test any contributions against a real DECnet implementation.

So I'll provide what help I can to anybody who wants to take the role
on, within those limitations. I'm also happy to answer questions about
why things were done in a particular way, for example.

It is good to know that people are still using the Linux DECnet code
too. It has lived far beyond the time when I'd envisioned it still being
useful :-)

Steve.

> 
> 
> 
> Philipp Schafft <lion@lion.leolix.org> wrote on 29/11/2011 14:47:19:
> 
> > reflum,
> > 
> > On Tue, 2011-11-29 at 15:34 +0100, Steven Whitehouse wrote:
> > 
> > > Has anybody actually tested it
> > > > >> lately against "real" DEC implementations?
> > > > > I doubt it :-)
> > > > DECnet is in use against real DEC implementations - I have
> checked it 
> > > > quite recently against a VAX running OpenVMS. How many people
> are 
> > > > actually using it for real work is a different question though.
> > > > 
> > > Ok, thats useful info.
> > 
> > I confirmed parts of it with tcpdump and the specs some weeks ago.
> The
> > parts I worked on passed :) I also considered to send the tcpdump
> > upstream a patch for protocol decoding.
> > 
> > 
> > > > It's also true that it's not really supported by anyone as I
> orphaned it 
> > > > some time ago and nobody else seems to care enough to take it
> over. So 
> > > > if it's becoming a burden on people doing real kernel work then
> I don't 
> > > > think many tears will be wept for its removal.
> > > > Chrissie
> > > 
> > > Really the only issue with keeping it around is the maintenance
> burden I
> > > think. It doesn't look like anybody wants to take it on, but maybe
> we
> > > should give it another few days for someone to speak up, just in
> case
> > > they are on holiday or something at the moment.
> > > 
> > > Also, I've updated the subject of the thread, to make it more
> obvious
> > > what is being discussed, as well as bcc'ing it again to the DECnet
> list,
> > 
> > I'm very interested in the module. However my problem is that I had
> > nothing to do with kernel coding yet. However I'm currently
> searching a
> > new maintainer for it (I got info about this thread by today).
> > If somebody is interested in this and only needs some "motivation"
> or
> > maybe someone would like to get me into kernel coding, please just
> > reply :)
> > 
> > -- 
> > Philipp.
> > (Rah of PH2)
> > [attachment "signature.asc" deleted by Mike Gair/UK/Corus] 
> >
> ------------------------------------------------------------------------------
> > All the data continuously generated in your IT infrastructure 
> > contains a definitive record of customers, application performance, 
> > security threats, fraudulent activity, and more. Splunk takes this 
> > data and makes sense of it. IT sense. And common sense.
> > http://p.sf.net/sfu/splunk-novd2d
> > _______________________________________________
> > Project Home Page: http://linux-decnet.wiki.sourceforge.net/
> > 
> > Linux-decnet-user mailing list
> > Linux-decnet-user@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/linux-decnet-user
> > 
> 
> 
> **********************************************************************
> This transmission is confidential and must not be used or disclosed by
> anyone other than the intended recipient. Neither Tata Steel Europe
> Limited nor any of its subsidiaries can accept any responsibility for
> any use or misuse of the transmission by anyone. 
> 
> For address and company registration details of certain entities
> within the Tata Steel Europe group of companies, please visit
> http://www.tatasteeleurope.com/entities
> **********************************************************************
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
