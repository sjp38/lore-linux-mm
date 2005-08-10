Date: Wed, 10 Aug 2005 16:38:02 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH/RFT 2/5] CLOCK-Pro page replacement
In-Reply-To: <20050810.132744.18577541.davem@davemloft.net>
Message-ID: <Pine.LNX.4.61.0508101637240.2695@chimarrao.boston.redhat.com>
References: <20050810200216.644997000@jumble.boston.redhat.com>
 <20050810200943.068937000@jumble.boston.redhat.com>
 <20050810.132744.18577541.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Aug 2005, David S. Miller wrote:
> From: Rik van Riel <riel@redhat.com>
> Date: Wed, 10 Aug 2005 16:02:18 -0400
> 
> > --- linux-2.6.12-vm.orig/fs/proc/proc_misc.c
> > +++ linux-2.6.12-vm/fs/proc/proc_misc.c
> > @@ -219,6 +219,20 @@ static struct file_operations fragmentat
> >  	.release	= seq_release,
> >  };
> >  
> > +extern struct seq_operations refaults_op;
> 
> Please put this in linux/mm.h or similar, so that we'll get proper
> type checking of the definition in nonresident.c

The reason it is in fs/proc/proc_misc.c is that the rest of
these definitions are there.

I agree with you though, it would be a good thing if they
moved into a header file.

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
