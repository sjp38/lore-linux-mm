Date: Tue, 1 May 2007 02:15:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: nfsd/md patches Re: 2.6.22 -mm merge plans
Message-Id: <20070501021525.beef1e78.akpm@linux-foundation.org>
In-Reply-To: <20070501090843.GB17949@infradead.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<17974.34116.479061.912980@notabene.brown>
	<20070501090843.GB17949@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007 10:08:43 +0100 Christoph Hellwig <hch@infradead.org> wrote:

> apropos nfsd patches, what's the merge plans for my two export ops
> patch series?

box:/usr/src/25/patches> grep -l '^From:.*hch' $(cat-series ../series )
dvb_en_50221-convert-to-kthread-api.patch
simplify-the-stacktrace-code.patch
vfs-remove-superflous-sb-==-null-checks.patch
nameic-remove-utterly-outdated-comment.patch
move-die-notifier-handling-to-common-code.patch
merge-compat_ioctlh-into-compat_ioctlc.patch
cleanup-compat-ioctl-handling.patch
kprobes-use-hlist_for_each_entry.patch
kprobes-codingstyle-cleanups.patch
kprobes-kretprobes-simplifcations.patch

I give up.  Where are they hiding?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
