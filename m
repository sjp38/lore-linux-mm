Date: Sat, 24 Mar 2001 00:37:16 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <E14gZvi-0005YW-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.30.0103240030310.13864-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Guest section DW <dwguest@win.tue.nl>, Stephen Clouse <stephenc@theiqgroup.com>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2001, Alan Cox wrote:
> > > and rely on it. You might find you need a few Gbytes of swap just to
> > > boot
> > Seems a bit exaggeration ;) Here are numbers,
> NetBSD is if I remember rightly still using a.out library styles.

No, it uses ELF today, moreover the numbers were from Solaris. NetBSD
also switched from non-overcommit to overcommit-only [AFAIK] mode with
"random" process killing with its new UVM.

> > 6-50% more VM and the performance hit also isn't so bad as it's thought
> > (Eduardo Horvath sent a non-overcommit patch for Linux about one year
> > ago).
> The Linux performance hit would be so close to zero you shouldnt be able to
> measure it - or it was in 1.2 anyway

Yep, something like this :)

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
