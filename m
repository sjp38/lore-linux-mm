Date: Wed, 15 Mar 2006 01:01:09 +0100 (MET)
From: "Michael Kerrisk" <mtk-manpages@gmx.net>
MIME-Version: 1.0
References: <Pine.LNX.4.64.0603060935300.24016@schroedinger.engr.sgi.com>
Subject: Inconsistent capabilites associated with MPOL_MOVE_ALL
Message-ID: <7277.1142380869@www015.gmx.net>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>, ak@suse.de
Cc: linux-mm@kvack.org, michael.kerrisk@gmx.net
List-ID: <linux-mm.kvack.org>

Andi, Christoph,

In the implementation of migrate_pages() one finds the following 
lines:

err = do_migrate_pages(mm, &old, &new, 
        capable(CAP_SYS_ADMIN) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);

while in the implemantation of mbind() we have:

if ((flags & MPOL_MF_MOVE_ALL( && !capable(CAP_SYS_RESOURCE))
        return -EPERM;

Is it really intended to associate two *different* capabilities 
with the operation of MPOL_MF_MOVE_ALL in this fashion?  At
first glance, it seems rather inconsistent to do so.

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
