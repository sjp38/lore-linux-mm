Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8867D6B005A
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 21:02:21 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so12931612qcq.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 18:02:20 -0800 (PST)
Date: Wed, 28 Nov 2012 18:02:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
In-Reply-To: <20121129012933.GA9112@kernel>
Message-ID: <alpine.LNX.2.00.1211281745200.1641@eggly.anvils>
References: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils> <20121129012933.GA9112@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Zheng Liu <wenqing.lz@taobao.com>, Jeff liu <jeff.liu@oracle.com>, Jim Meyering <jim@meyering.net>, Paul Eggert <eggert@cs.ucla.edu>, Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Dave Chinner <david@fromorbit.com>, Marco Stornelli <marco.stornelli@gmail.com>, Chris Mason <chris.mason@fusionio.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 29 Nov 2012, Jaegeuk Hanse wrote:
> On Wed, Nov 28, 2012 at 05:22:03PM -0800, Hugh Dickins wrote:
> >Revert 3.5's f21f8062201f ("tmpfs: revert SEEK_DATA and SEEK_HOLE")
> >to reinstate 4fb5ef089b28 ("tmpfs: support SEEK_DATA and SEEK_HOLE"),
> >with the intervening additional arg to generic_file_llseek_size().
> >
> >In 3.8, ext4 is expected to join btrfs, ocfs2 and xfs with proper
> >SEEK_DATA and SEEK_HOLE support; and a good case has now been made
> >for it on tmpfs, so let's join the party.
> >
> 
> Hi Hugh,
> 
> IIUC, several months ago you revert the patch. You said, 
> 
> "I don't know who actually uses SEEK_DATA or SEEK_HOLE, and whether it
> would be of any use to them on tmpfs.  This code adds 92 lines and 752
> bytes on x86_64 - is that bloat or worthwhile?"

YUC.

> 
> But this time in which scenario will use it?

I was not very convinced by the grep argument from Jim and Paul:
that seemed to be grep holding on to a no-arbitrary-limits dogma,
at the expense of its users, causing an absurd line-length issue,
which use of SEEK_DATA happens to avoid in some cases.

The cp of sparse files from Jeff and Dave was more convincing;
but I still didn't see why little old tmpfs needed to be ahead
of the pack.

But at LinuxCon/Plumbers in San Diego in August, a more convincing
case was made: I was hoping you would not ask, because I did not take
notes, and cannot pass on the details - was it rpm building on tmpfs?
I was convinced enough to promise support on tmpfs when support on
ext4 goes in.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
