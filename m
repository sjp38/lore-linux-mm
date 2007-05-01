Date: Tue, 1 May 2007 10:21:45 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: nfsd/md patches Re: 2.6.22 -mm merge plans
Message-ID: <20070501092145.GA21015@infradead.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <17974.34116.479061.912980@notabene.brown> <20070501090843.GB17949@infradead.org> <20070501021525.beef1e78.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070501021525.beef1e78.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 01, 2007 at 02:15:25AM -0700, Andrew Morton wrote:
> On Tue, 1 May 2007 10:08:43 +0100 Christoph Hellwig <hch@infradead.org> wrote:
> 
> > apropos nfsd patches, what's the merge plans for my two export ops
> > patch series?

This question was directed to Neil, sorry.  

> box:/usr/src/25/patches> grep -l '^From:.*hch' $(cat-series ../series )
> dvb_en_50221-convert-to-kthread-api.patch
> simplify-the-stacktrace-code.patch
> vfs-remove-superflous-sb-==-null-checks.patch
> nameic-remove-utterly-outdated-comment.patch
> move-die-notifier-handling-to-common-code.patch
> merge-compat_ioctlh-into-compat_ioctlc.patch
> cleanup-compat-ioctl-handling.patch
> kprobes-use-hlist_for_each_entry.patch
> kprobes-codingstyle-cleanups.patch
> kprobes-kretprobes-simplifcations.patch
> 
> I give up.  Where are they hiding?

Good question :)  I sent them to the nfs list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
