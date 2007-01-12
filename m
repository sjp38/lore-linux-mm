Date: Fri, 12 Jan 2007 13:25:50 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: High lock spin time for zone->lru_lock under extreme conditions
Message-Id: <20070112132550.dc007698.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0701121137430.2306@schroedinger.engr.sgi.com>
References: <20070112160104.GA5766@localhost.localdomain>
	<Pine.LNX.4.64.0701121137430.2306@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>, pravin b shelar <pravin.shelar@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jan 2007 11:46:22 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> > While the softlockups and the like went away by enabling interrupts during
> > spinning, as mentioned in http://lkml.org/lkml/2007/1/3/29 ,
> > Andi thought maybe this is exposing a problem with zone->lru_locks and 
> > hence warrants a discussion on lkml, hence this post.  Are there any 
> > plans/patches/ideas to address the spin time under such extreme conditions?
> 
> Could this be a hardware problem? Some issue with atomic ops in the 
> Sun hardware?

I'd assume so.  We don't hold lru_lock for 33 seconds ;)

Probably similar symptoms are demonstrable using other locks, if a
suitable workload is chosen.

Increasing PAGEVEC_SIZE might help.  But we do allocate those things
on the stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
