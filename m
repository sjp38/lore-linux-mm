Date: Tue, 09 Nov 2004 12:09:52 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] Use MPOL_INTERLEAVE for tmpfs files
Message-ID: <463220000.1100030992@flay>
In-Reply-To: <Pine.LNX.4.44.0411091824070.5130-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0411091824070.5130-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Brent Casavant <bcasavan@sgi.com>
Cc: Andi Kleen <ak@suse.de>, "Adam J. Richter" <adam@yggdrasil.com>, colpatch@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I think the option should be "mpol=interleave" rather than just
> "interleave", who knows what baroque mpols we might want to support
> there in future?

Sounds sensible.
 
> I'm irritated to realize that we can't change the default for SysV
> shared memory or /dev/zero this way, because that mount is internal.

Boggle. shmem I can perfectly understand, and have been intending to
change for a while. But why /dev/zero ? Presumably you'd always want
that local?

Thanks,

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
