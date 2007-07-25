Date: Wed, 25 Jul 2007 13:34:01 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: -mm merge plans for 2.6.23
Message-ID: <20070725113401.GA23341@elte.hu>
References: <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com> <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm> <46A6DFFD.9030202@gmail.com> <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com> <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46A70D37.3060005@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Valdis.Kletnieks@vt.edu, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Rene Herman <rene.herman@gmail.com> wrote:

> On 07/25/2007 10:28 AM, Ingo Molnar wrote:
> 
> >>Regardless, I'll stand by "[by disabling updatedb] the problem will 
> >>for a large part be solved" as I expect approximately 94.372 percent 
> >>of Linux desktop users couldn't care less about locate.
> >
> > i think that approach is illogical: because Linux mis-handled a 
> > mixed workload the answer is to ... remove a portion of that 
> > workload?
> 
> No. It got snipped but I introduced the comment by saying it was a 
> "that's not the point" kind of thing. [...]

ok - with that qualification i understand.

still, especially for someone like me who frequently deals with source 
code, 'locate' is indispensible.

and the fact is: updatedb discards a considerable portion of the cache 
completely unnecessarily: on a reasonably complex box no way do all the 
inodes and dentries fit into all of RAM, so we just trash everything. 
Maybe the kernel could be extended with a method of opening files in a 
'drop from the dcache after use' way. (beagled and backup tools could 
make use of that facility too.) (Or some other sort of 
file-cache-invalidation syscall that already exist, which would _also_ 
result in the immediate zapping of the dentry+inode from the dcache.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
