Date: Tue, 14 Mar 2006 16:09:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
In-Reply-To: <7277.1142380869@www015.gmx.net>
Message-ID: <Pine.LNX.4.64.0603141608350.22835@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603060935300.24016@schroedinger.engr.sgi.com>
 <7277.1142380869@www015.gmx.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Kerrisk <mtk-manpages@gmx.net>
Cc: ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Michael Kerrisk wrote:

> err = do_migrate_pages(mm, &old, &new, 
>         capable(CAP_SYS_ADMIN) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
> 
> while in the implemantation of mbind() we have:
> 
> if ((flags & MPOL_MF_MOVE_ALL( && !capable(CAP_SYS_RESOURCE))
>         return -EPERM;
> 
> Is it really intended to associate two *different* capabilities 
> with the operation of MPOL_MF_MOVE_ALL in this fashion?  At
> first glance, it seems rather inconsistent to do so.

You are likely right. Which one is the more correct capability to use?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
