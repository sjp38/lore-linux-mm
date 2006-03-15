Date: Wed, 15 Mar 2006 02:07:57 +0100 (MET)
From: "Michael Kerrisk" <mtk-manpages@gmx.net>
MIME-Version: 1.0
References: <20060314170111.7c2203a0.akpm@osdl.org>
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
Message-ID: <15030.1142384877@www015.gmx.net>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.comclameter@sgi.com, ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net
List-ID: <linux-mm.kvack.org>

> Von: Andrew Morton <akpm@osdl.org>
> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > On Tue, 14 Mar 2006, Andrew Morton wrote:
> > 
> > > Christoph Lameter <clameter@sgi.com> wrote:
> > > >
> > > > Use CAP_SYS_NICE for controlling migration permissions.
> > > ahem.  Kind of eleventh-hour.  Are we really sure?
> > 
> > This may still get into 2.6.16???
> 
> Well it changes the userspace API.

No -- both of these changes affect interfaces
that are only part of the unreleased 2.6.16. 
(MPOL_MF_MOVE_ALL is new in 2.6.16.)

Cheers,

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
