Date: Wed, 15 Mar 2006 01:40:56 +0100 (MET)
From: "Michael Kerrisk" <mtk-manpages@gmx.net>
MIME-Version: 1.0
References: <Pine.LNX.4.64.0603141632210.23051@schroedinger.engr.sgi.com>
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
Message-ID: <32623.1142383256@www015.gmx.net>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net
List-ID: <linux-mm.kvack.org>

> --- Ursprungliche Nachricht ---
> Von: Christoph Lameter <clameter@sgi.com>
> An: akpm@osdl.org
> Kopie: Michael Kerrisk <mtk-manpages@gmx.net>, ak@suse.de,
> linux-mm@kvack.org, michael.kerrisk@gmx.net
> Betreff: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
> Datum: Tue, 14 Mar 2006 16:33:29 -0800 (PST)
> 
> On Wed, 15 Mar 2006, Michael Kerrisk wrote:
> 
> > It seems to me that setting scheduling policy and 
> > priorities is also the kind of thing that might be performed 
> > in apps that also use the NUMA API, so it would seem consistent 
> > to use CAP_SYS_NICE for NUMA also.
> 
> Use CAP_SYS_NICE for controlling migration permissions.

Ahhh -- the sweet smell of consistency...

Thanks!

Michael

-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7 

Want to help with man page maintenance?  
Grab the latest tarball at
ftp://ftp.win.tue.nl/pub/linux-local/manpages/, 
read the HOWTOHELP file and grep the source 
files for 'FIXME'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
