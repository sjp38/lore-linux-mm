From: "Michael Kerrisk" <michael.kerrisk@gmx.net>
Date: Wed, 15 Mar 2006 14:12:00 +1300
MIME-Version: 1.0
Subject: Re: Inconsistent capabilites associated with MPOL_MOVE_ALL
Message-ID: <441820B0.6719.396D781@michael.kerrisk.gmx.net>
In-reply-to: <15030.1142384877@www015.gmx.net>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.comclameter@sgi.com, ak@suse.de, linux-mm@kvack.org, michael.kerrisk@gmx.net, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

> > Von: Andrew Morton <akpm@osdl.org>
> > Christoph Lameter <clameter@sgi.com> wrote:
> > >
> > > On Tue, 14 Mar 2006, Andrew Morton wrote:
> > > 
> > > > Christoph Lameter <clameter@sgi.com> wrote:
> > > > >
> > > > > Use CAP_SYS_NICE for controlling migration permissions.
> > > > ahem.  Kind of eleventh-hour.  Are we really sure?
> > > 
> > > This may still get into 2.6.16???
> > 
> > Well it changes the userspace API.
> 
> No -- both of these changes affect interfaces
> that are only part of the unreleased 2.6.16. 
> (MPOL_MF_MOVE_ALL is new in 2.6.16.)

Replying to self...

Ooops sorry about the last -- I see that Christoph is changing stuff in 
addition to what I was proposing...  (But it makes sense to me, from a 
consistency point of view.)

Cheers,

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
