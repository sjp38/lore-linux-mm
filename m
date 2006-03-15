Date: Tue, 14 Mar 2006 17:01:11 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
Message-Id: <20060314170111.7c2203a0.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603141648570.23152@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141608350.22835@schroedinger.engr.sgi.com>
	<23583.1142382327@www015.gmx.net>
	<Pine.LNX.4.64.0603141632210.23051@schroedinger.engr.sgi.com>
	<20060314164138.5912ce82.akpm@osdl.org>
	<Pine.LNX.4.64.0603141648570.23152@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mtk-manpages@gmx.net, ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Tue, 14 Mar 2006, Andrew Morton wrote:
> 
> > Christoph Lameter <clameter@sgi.com> wrote:
> > >
> > > Use CAP_SYS_NICE for controlling migration permissions.
> > ahem.  Kind of eleventh-hour.  Are we really sure?
> 
> This may still get into 2.6.16???

Well it changes the userspace API.

> Then I'd also like to have 
> the documentation update in and the fix for the retries on VM_LOCKED.

gargh, pelase don't send me off to read hundreds of patches to work out
which one you're referring to :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
