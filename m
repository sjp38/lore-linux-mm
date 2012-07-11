Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 856F56B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 03:56:35 -0400 (EDT)
Date: Wed, 11 Jul 2012 00:59:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2012-07-10-16-59 uploaded
Message-Id: <20120711005926.25acc6c6.akpm@linux-foundation.org>
In-Reply-To: <1341993193.2963.132.camel@sauron>
References: <20120711000148.BAD1E5C0050@hpza9.eem.corp.google.com>
	<1341988680.2963.128.camel@sauron>
	<20120711004430.0d14f0b6.akpm@linux-foundation.org>
	<1341993193.2963.132.camel@sauron>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dedekind1@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Wed, 11 Jul 2012 10:53:13 +0300 Artem Bityutskiy <dedekind1@gmail.com> wrote:

> On Wed, 2012-07-11 at 00:44 -0700, Andrew Morton wrote:
> > On Wed, 11 Jul 2012 09:38:00 +0300 Artem Bityutskiy <dedekind1@gmail.com> wrote:
> > 
> > > Andrew, thanks for picking my changes!
> > > 
> > > On Tue, 2012-07-10 at 17:01 -0700, akpm@linux-foundation.org wrote:
> > > > * hfs-get-rid-of-hfs_sync_super-checkpatch-fixes.patch
> > > 
> > > > * hfsplus-get-rid-of-write_super-checkpatch-fixes.patch
> > > 
> > > I sent updated versions which would fix checkpatch.pl complaints. I
> > > guess you did not notice them or was unable to pick because I think I
> > > PGP-signed them?
> > 
> > I looked at them, but they're identical to what I now have, so nothing
> > needed doing.
> 
> Strange, I thought they had the white-spaces issue solved. 

They did, but I'd already fixed everything.  That's what those emails
in your inbox were about.

> I'll resend the entire series.

argh, no, not again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
