Date: Wed, 03 Nov 2004 13:00:44 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] Use MPOL_INTERLEAVE for tmpfs files
Message-ID: <276730000.1099515644@flay>
In-Reply-To: <Pine.SGI.4.58.0411031021160.79310@kzerza.americas.sgi.com>
References: <239530000.1099435919@flay> <Pine.LNX.4.44.0411030826310.6096-100000@localhost.localdomain><20041103090112.GJ8907@wotan.suse.de> <Pine.SGI.4.58.0411031021160.79310@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>, Andi Kleen <ak@suse.de>, colpatch@us.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--On Wednesday, November 03, 2004 10:32:56 -0600 Brent Casavant <bcasavan@sgi.com> wrote:

> On Wed, 3 Nov 2004, Andi Kleen wrote:
> 
>> If you want to go more finegraid then you can always use numactl
>> or even libnuma in the application.  For a quick policy decision a sysctl
>> is fine imho.
> 
> OK, so I'm not seeing a definitive stance by the interested parties
> either way.  So since the code's already done, I'm posting the sysctl
> method, and defaulting to on.  I assume that if we later decide that
> a mount option was correct after all, that it's no big deal to axe the
> sysctl?

Matt has volunteered to write the mount option for this, so let's hold
off for a couple of days until that's done.

M

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
