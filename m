Date: Mon, 23 Jul 2007 14:53:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/6] cpuset aware writeback
In-Reply-To: <46A51DEB.6090603@google.com>
Message-ID: <Pine.LNX.4.64.0707231452290.32152@schroedinger.engr.sgi.com>
References: <469D3342.3080405@google.com> <20070723131841.02c9b109@schroedinger.engr.sgi.com>
 <46A51DEB.6090603@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007, Ethan Solomita wrote:

> Christoph Lameter wrote:
> > On Tue, 17 Jul 2007 14:23:14 -0700
> > Ethan Solomita <solo@google.com> wrote:
> > 
> >> These patches are mostly unchanged from Chris Lameter's original
> >> changelist posted previously to linux-mm.
> > 
> > Thanks for keeping these patches up to date. Add you signoff if you
> > did modifications to a patch. Also include the description of the tests
> > in the introduction to the patchset.
> 
> 	So switch from an Ack to a signed-off? OK, and I'll add descriptions of

No. Do a signed-off if you have modified the patch.

> testing. Everyone other than you has been silent on these patches. Does
> silence equal consent?

Sometimes. Howerver, the audience for NUMA and cpusets is rather limited.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
