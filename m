Date: Thu, 8 May 2003 09:30:11 +0200
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
Message-ID: <20030508073011.GA378@hh.idb.hist.no>
References: <3EB8E4CC.8010409@aitel.hist.no> <20030507.025626.10317747.davem@redhat.com> <20030507144100.GD8978@holomorphy.com> <20030507.064010.42794250.davem@redhat.com> <20030507215430.GA1109@hh.idb.hist.no> <20030508013854.GW8931@holomorphy.com> <20030508065440.GA1890@hh.idb.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030508065440.GA1890@hh.idb.hist.no>
From: Helge Hafting <helgehaf@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: William Lee Irwin III <wli@holomorphy.com>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2003 at 08:54:40AM +0200, Helge Hafting wrote:
> On Wed, May 07, 2003 at 06:38:54PM -0700, William Lee Irwin III wrote:
> [...] 
> > Can you try one kernel with the netfilter cset backed out, and another
> > with the re-slabification patch backed out? (But not with both backed
> > out simultaneously).
> 
> I'm compiling without reslabify now.
The 2.5.69-mm2 kernel without reslabify died in the same way.
10 minutes of nethack and I got the same oops.
I'm not sure about netfilter, so I'll simply try a kernel
with the filter deselected.

Helge Hafting
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
