Date: Thu, 31 Jul 2008 01:11:31 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
Message-ID: <20080731001131.GA30900@shareable.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: torvalds@linux-foundation.org, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > And by papering it over, it then just makes people less likely to bother 
> > with the real issue.
> 
> I think you are talking about a totally separate issue: that NFSD's
> use of splice can result in strange things if the file is truncated
> while being read.  But this is an NFSD issue and I don't see that it
> has _anything_ to do with the above bug in splice.  I think you are
> just confusing the two things.

I'm more concerned by sendfile() users like Apache, Samba, FTPd.  In
an earlier thread on this topic, I asked if the splice bug can also
result in sendfile() sending blocks of zeros, when a file is truncated
after it has been sent, and the answer was yes probably.

Not that I checked or anything.  But if it affects sendfile() it's a
bigger deal - that has many users.

Assuming it does affect sendfile(), it's exasperated by not being able
to tell when a sendfile() has finished with the pages its sending.
E.g. you can't lock the file or otherwise synchronise with another
program which wants to modify the file.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
