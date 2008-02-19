Received: by wa-out-1112.google.com with SMTP id m33so3684828wag.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 04:06:50 -0800 (PST)
Message-ID: <4cefeab80802190406w5dfcb257p1abff260c63522bc@mail.gmail.com>
Date: Tue, 19 Feb 2008 17:36:50 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: [linux-mm-cc] Announce: ccache release 0.1
In-Reply-To: <fd87b6160802190233q7a6b95ecrff29ca70a9927e3b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
	 <fd87b6160802190233q7a6b95ecrff29ca70a9927e3b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John McCabe-Dansted <gmatht@gmail.com>
Cc: linux-mm-cc@laptop.org, linux-mm@kvack.org, linuxcompressed-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 4:03 PM, John McCabe-Dansted <gmatht@gmail.com> wrote:
> On Feb 19, 2008 6:39 AM, Nitin Gupta <nitingupta910@gmail.com> wrote:
> > Some performance numbers for allocator and de/compressor can be found
> > on project home. Currently it is tested on Linux kernel 2.6.23.x and
> > 2.6.25-rc2 (x86 only). Please mail me/mailing-list any
> > issues/suggestions you have.
>
> It caused Gutsy (2.6.22-14-generic) to crash when I did a swap off of
> my hdd swap. I have a GB of ram, so I would have been fine without
> ccache.

These days "desktops with small memory" probably means virtual
machines with, say, <512M RAM :-)

>
> I had swapped on a 400MB ccache swap.
>

I need /var/log/messages (or whatever file kernel logs to in Gutsy) to
debug this.
Please send it to me offline if its too big.

> BTW, why is the default 10% of mem?

I have no great justification for "10%".

> This refers to the size of the
> block device right? So even 100% would probably only use 50% of
> physical memory for swap, assuming a 2:1 compression ratio.
>

Yes, this is correct.

Thanks,
- Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
