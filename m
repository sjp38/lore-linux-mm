Date: Wed, 11 Jul 2007 20:41:44 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
Message-ID: <20070711204143.GA3921@ucw.cz>
References: <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de> <46A85D95.509@kingswood-consulting.co.uk> <20070726092025.GA9157@elte.hu> <20070726023401.f6a2fbdf.akpm@linux-foundation.org> <20070726094024.GA15583@elte.hu> <20070726102025.GJ27237@ftp.linux.org.uk> <20070726122330.GA21750@one.firstfloor.org> <20070726145952.GK27237@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070726145952.GK27237@ftp.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ftp.linux.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi!

> > That would just save reading the directories. Not sure
> > it helps that much. Much better would be actually if it didn't stat the 
> > individual files (and force their dentries/inodes in). I bet it does that to 
> > find out if they are directories or not. But in a modern system it could just 
> > check the type in the dirent on file systems that support 
> > that and not do a stat. Then you would get much less dentries/inodes.
>  
> FWIW, find(1) does *not* stat non-directories (and neither would this
> approach).  So it's just dentries for directories and you can't realistically
> skip those.  OK, you could - if you had banned cross-directory rename
> for directories and propagated "dirty since last look" towards root (note
> that it would be a boolean, not a timestamp).  Then we could skip unchanged
> subtrees completely...

Could we help it a little from kernel and set 'dirty since last look'
on directory renames?

I mean, this is not only updatedb. KDE startup is limited by this,
too. It would be nice to have effective 'what change in tree'
operation.
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
