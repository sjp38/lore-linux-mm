Message-ID: <37EB3C86.F17CC25A@transmeta.com>
Date: Fri, 24 Sep 1999 01:55:34 -0700
From: "H. Peter Anvin" <hpa@transmeta.com>
MIME-Version: 1.0
Subject: Re: syslinux-1.43 bug [and possible PATCH]
References: <199909232109.OAA13866@google.engr.sgi.com> <99Sep24.094756bst.66313@gateway.ukaea.org.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Conway <nconway.list@UKAEA.ORG.UK>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, syslinux@linux.kernel.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Neil Conway wrote:
> 
> > Have other people run into this problem and worked around it some
> > other way? (One way would be to specify mem= at the boot: prompt
> > from syslinux. Yet another way seems to be to specify mem= in
> > the syslinux.cfg file. Changing HIGHMEM_MAX seems to be the cleanest,
> > although I am not sure whether this will impact the capability of
> > syslinux to install other os'es).
> 
> I don't think "mem=" would help at all but I could be wrong.
> 

It works; both SYSLINUX and the kernel with honour it.

> My "easy" fix was to pull out a DIMM from each of our machines, leaving
> 3x256 :-)  Not elegant, but fast!

As already said, get SYSLINUX 1.44 or later...

	-hpa
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
