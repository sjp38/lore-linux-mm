Date: Tue, 14 Mar 2006 16:53:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
In-Reply-To: <20060314164138.5912ce82.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603141648570.23152@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141608350.22835@schroedinger.engr.sgi.com>
 <23583.1142382327@www015.gmx.net> <Pine.LNX.4.64.0603141632210.23051@schroedinger.engr.sgi.com>
 <20060314164138.5912ce82.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, mtk-manpages@gmx.net, ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net
List-ID: <linux-mm.kvack.org>

On Tue, 14 Mar 2006, Andrew Morton wrote:

> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > Use CAP_SYS_NICE for controlling migration permissions.
> ahem.  Kind of eleventh-hour.  Are we really sure?

This may still get into 2.6.16??? Then I'd also like to have 
the documentation update in and the fix for the retries on VM_LOCKED. The 
VM_LOCKED patch changes the migration API for filesystems and I really 
would like to limit the changes after 2.6.16 is out.

Michael had the first intelligent comment on the use of the 
capabilities in page migration that I have seen and he actually made 
more sense than my reasoning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
