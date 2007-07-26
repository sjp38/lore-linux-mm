Date: Thu, 26 Jul 2007 15:59:52 +0100
From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Message-ID: <20070726145952.GK27237@ftp.linux.org.uk>
References: <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de> <46A85D95.509@kingswood-consulting.co.uk> <20070726092025.GA9157@elte.hu> <20070726023401.f6a2fbdf.akpm@linux-foundation.org> <20070726094024.GA15583@elte.hu> <20070726102025.GJ27237@ftp.linux.org.uk> <20070726122330.GA21750@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070726122330.GA21750@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 26, 2007 at 02:23:30PM +0200, Andi Kleen wrote:
> That would just save reading the directories. Not sure
> it helps that much. Much better would be actually if it didn't stat the 
> individual files (and force their dentries/inodes in). I bet it does that to 
> find out if they are directories or not. But in a modern system it could just 
> check the type in the dirent on file systems that support 
> that and not do a stat. Then you would get much less dentries/inodes.
 
FWIW, find(1) does *not* stat non-directories (and neither would this
approach).  So it's just dentries for directories and you can't realistically
skip those.  OK, you could - if you had banned cross-directory rename
for directories and propagated "dirty since last look" towards root (note
that it would be a boolean, not a timestamp).  Then we could skip unchanged
subtrees completely...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
