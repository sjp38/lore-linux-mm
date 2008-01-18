From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped files
Date: Fri, 18 Jan 2008 23:32:00 +0100
References: <12006091182260-git-send-email-salikhmetov@gmail.com> <E1JFwnQ-0001FB-2c@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801181127000.2957@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.00.0801181127000.2957@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801182332.02945.ioe-lkml@rameria.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

On Friday 18 January 2008, Linus Torvalds wrote:
> On Fri, 18 Jan 2008, Miklos Szeredi wrote:
> > 
> > What I'm saying is that the times could be left un-updated for a long
> > time if program doesn't do munmap() or msync(MS_SYNC) for a long time.
> 
> Sure.
> 
> But in those circumstances, the programmer cannot depend on the mtime 
> *anyway* (because there is no synchronization), so what's the downside?

Can we get "if the write to the page hits the disk, the mtime has hit the disk
already no less than SOME_GRANULARITY before"? 

That is very important for computer forensics. Esp. in saving your ass!

Ok, now back again to making that fast :-)


Best Regards

Ingo Oeser

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
