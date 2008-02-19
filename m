Received: by wa-out-1112.google.com with SMTP id m33so3806873wag.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 08:46:52 -0800 (PST)
Message-ID: <4cefeab80802190846v5ed29b93g43e83cd3448d765e@mail.gmail.com>
Date: Tue, 19 Feb 2008 22:16:52 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: [linux-mm-cc] Announce: ccache release 0.1
In-Reply-To: <fd87b6160802190816s3f2bf684q1eeb24d0ee2dfd23@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
	 <fd87b6160802190816s3f2bf684q1eeb24d0ee2dfd23@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John McCabe-Dansted <gmatht@gmail.com>
Cc: linux-mm-cc@laptop.org, linux-mm@kvack.org, linuxcompressed-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 9:46 PM, John McCabe-Dansted <gmatht@gmail.com> wrote:
> On Feb 19, 2008 6:39 AM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> > Hi All,
> >
> > I am excited to announce first release of ccache - Compressed RAM
> > based swap device for Linux (2.6.x kernel).
> >   - Project home: http://code.google.com/p/ccache/
> >   - ccache-0.1: http://ccache.googlecode.com/files/ccache-0.1.tar.bz2
>
> I find it counter intuitive that ccache-0.1 is newer than ccache-2.4:
> http://ccache.samba.org/
>
> Perhaps you should rename this, perhaps to ccacheM (module).
>

My bad. I knew there is going to be confusion with
http://ccache.samba.org/ which has _nothing_ to do with this project.

I am now going to rename this project to "compcache" to avoid any confusion.
New project home will be: http://code.google.com/p/compcache/
It will take few days for this transition to complete.

> FYI, ccache still seems solid under Hardy.
> A 128MB ccache swap allowed me to easily install from the liveCD on a
> VM with only 192MB of ram, rather than the 384MB officially required
> for Gutsy.
> However I found a funny bug in ubiquity:
>   https://bugs.launchpad.net/bugs/193267
>   http://www.ucc.asn.au/~mccabedj/ccache/Screenshot-Hardy-fdccache.png
> Installing Hardy to /dev/ccache sound like a great idea ;)

Yeah. Interesting :)  - /dev/ccache really should not be visible there
since its _not_ possible to install on this device! This is not a
_generic_ block device and can be used only as a swap disk. However, I
am not sure how to make it invisible to installer (maybe load module
after partitioning step is over?).

>
> I am using a DualCore, with the iso sitting on the harddisk, so a real
> low-mem machine could be a lot slower.  however Ubuntu is meant to
> require 384MB of memory to install and 256MB of memory to use. It
> seems that by adding ccache to the liveCD we could just state a single
> figure of 256MB (which is 64MB less than 256MB, so we are giving
> ourselves plenty of breathing space for RAM stealing video cards,
> unexpected usage spikes etc.)
>
>
> --
> John C. McCabe-Dansted
> PhD Student
> University of Western Australia
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
