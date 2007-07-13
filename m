Date: Fri, 13 Jul 2007 10:31:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] do not limit locked memory when RLIMIT_MEMLOCK is
 RLIM_INFINITY
Message-Id: <20070713103132.38e782e5.akpm@linux-foundation.org>
In-Reply-To: <46979C4E.6000205@oracle.com>
References: <4692D9E0.1000308@oracle.com>
	<20070713004408.b7162501.akpm@linux-foundation.org>
	<46979C4E.6000205@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave McCracken <dave.mccracken@oracle.com>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007 08:37:50 -0700 Herbert van den Bergh <herbert.van.den.bergh@oracle.com> wrote:

> Andrew Morton wrote:
> > 
> > OK.  Seems like a nasty bug if one happens to want to do that.  Should we
> > backport this into 2.6.22.x?
> > 
> 
> Yes, please.  Do you need me to do anything for that?
> 

Nope.  I stick a "Cc: <stable@kernel.org>" into the changelog and then
magic happens: the -stable maintainers get a copy of the patch when it goes
to Linus, they get notification when I drop it after Linus merged it and
then they (hopeully) take the patch from Linus's tree.

(But the last step is a bit of a hassle - I suspect they take my emailed
version instead, but it would be super-rare for that to differ from the
version which Linus merged)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
