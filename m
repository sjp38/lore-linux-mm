Received: by wr-out-0506.google.com with SMTP id 60so2156559wri.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 06:05:00 -0800 (PST)
Message-ID: <4cefeab80802190604g1c9fea72ge1052cb3bd597e0a@mail.gmail.com>
Date: Tue, 19 Feb 2008 19:34:59 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: [linux-mm-cc] Announce: ccache release 0.1
In-Reply-To: <fd87b6160802190507g74e64866pdbbda84826e0e5b8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
	 <fd87b6160802190233q7a6b95ecrff29ca70a9927e3b@mail.gmail.com>
	 <4cefeab80802190406w5dfcb257p1abff260c63522bc@mail.gmail.com>
	 <fd87b6160802190507g74e64866pdbbda84826e0e5b8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John McCabe-Dansted <gmatht@gmail.com>
Cc: linux-mm-cc@laptop.org, linux-mm@kvack.org, linuxcompressed-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 6:37 PM, John McCabe-Dansted <gmatht@gmail.com> wrote:
> On Feb 19, 2008 9:06 PM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> > On Feb 19, 2008 4:03 PM, John McCabe-Dansted <gmatht@gmail.com> wrote:
> > > On Feb 19, 2008 6:39 AM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> > > > Some performance numbers for allocator and de/compressor can be found
> > > > on project home. Currently it is tested on Linux kernel 2.6.23.x and
> > > > 2.6.25-rc2 (x86 only). Please mail me/mailing-list any
> > > > issues/suggestions you have.
> > >
> > > It caused Gutsy (2.6.22-14-generic) to crash when I did a swap off of
> > > my hdd swap. I have a GB of ram, so I would have been fine without
> > > ccache.
> >
> > These days "desktops with small memory" probably means virtual
> > machines with, say, <512M RAM :-)
>
> The Hardy liveCD is really snappy with a 192MB VM and and a 128MB
> ccache swap. :)
>

Good to know :)

> > > I had swapped on a 400MB ccache swap.
> > >
> >
> > I need /var/log/messages (or whatever file kernel logs to in Gutsy) to
> > debug this.
> > Please send it to me offline if its too big.
>
> This seems to be the bit you want:
>

Unfortunately none of these messages suggest why crash happened.
If you can send entire log, that will probably be more useful.


> ubuntu-xp syslogd 1.4.1#21ubuntu3: restart.
> Feb 19 08:07:31 ubuntu-xp -- MARK --
> ...
> Feb 19 18:47:31 ubuntu-xp -- MARK --
> Feb 19 18:59:51 ubuntu-xp kernel: [377208.185464] ccache: Unknown
> symbol lzo1x_decompress_safe
<snip>

All these 'Unknown symbol' messages are because you tried loading
ccache.ko module before tlsf.ko and lzo*.ko modules.

>
> > > BTW, why is the default 10% of mem?
> >
> > I have no great justification for "10%".
>
> Perhaps 100% (or maybe 50%) would be a more sensible default? For me
> 66% makes a huge difference to the Hardy liveCD performance. 10% makes
> a difference but 50%+ goes from "ls /" taking 10s to snappy
> performance even on large applications like Firefox.
>

I think this depends a lot on kind of workload and system. For e.g:
- On desktops, retaining too many anonymous pages at cost of
continuously losing page-cache (filesystem-backed) pages can hurt
performance for workload that repeatedly access same file(s).
- On embedded systems, too much de/compression will drain all battery.
and so on...

Also, I don't know which of  these use cases is more "common".

- Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
