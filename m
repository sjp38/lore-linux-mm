Date: Wed, 10 Nov 2004 14:20:42 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Use MPOL_INTERLEAVE for tmpfs files
In-Reply-To: <Pine.SGI.4.58.0411092020550.101942@kzerza.americas.sgi.com>
Message-ID: <Pine.LNX.4.44.0411101406360.2806-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andi Kleen <ak@suse.de>, "Adam J. Richter" <adam@yggdrasil.com>, colpatch@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2004, Brent Casavant wrote:
> On Tue, 9 Nov 2004, Hugh Dickins wrote:
> 
> > Doesn't quite play right with what was my "NULL sbinfo" convention.
> 
> Howso?  I thought it played quite nicely with it.  We've been using
> NULL sbinfo as an indicator that an inode is from tmpfs rather than
> from SysV or /dev/zero.  Or at least that's the way my brain was
> wrapped around it.

That was the case you cared about, but remember I extended yours so
that tmpfs mounts could also suppress limiting, and get NULL sbinfo.

> The NULL sbinfo scheme worked perfectly for me, with very little hassle.

Yes, it would have worked just right for the important cases.

> > but they're two hints that I should rework that to get out of people's
> > way.  I'll do a patch for that, then another something like yours on
> > top, for you to go back and check.
> 
> Is this something imminent, or on the "someday" queue?  Just asking
> because I'd like to avoid doing additional work that might get thrown
> away soon.

I understand your concern ;)  I'm working on it, today or tomorrow.

> > I'm irritated to realize that we can't change the default for SysV
> > shared memory or /dev/zero this way, because that mount is internal.
> 
> Well, the only thing preventing this is that I stuck the flag into
> sbinfo, since it's an filesystem-wide setting.  I don't see any reason
> we couldn't add a new flag in the inode info flag field instead.  I
> think there would also be some work to set pvma.vm_end more precisely
> (in mpol_shared_policy_init()) in the SysV case.

It's not a matter of where to store the info, it's that we don't have
a user interface for remounting something that's not mounted anywhere.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
