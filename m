Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B97BA6B0088
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 08:09:16 -0500 (EST)
Date: Fri, 24 Dec 2010 05:04:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2010-12-23-16-58 uploaded
Message-Id: <20101224050459.0331deb7.akpm@linux-foundation.org>
In-Reply-To: <AANLkTinegsqmSzXqqrF930abQfOBu6_MH1EToupKV214@mail.gmail.com>
References: <201012240132.oBO1W8Ub022207@imap1.linux-foundation.org>
	<AANLkTinegsqmSzXqqrF930abQfOBu6_MH1EToupKV214@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: sedat.dilek@gmail.com
Cc: Sedat Dilek <sedat.dilek@googlemail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Dec 2010 13:15:26 +0100 Sedat Dilek <sedat.dilek@googlemail.com> wrote:

> On Fri, Dec 24, 2010 at 1:58 AM,  <akpm@linux-foundation.org> wrote:
> > The mm-of-the-moment snapshot 2010-12-23-16-58 has been uploaded to
> >
> > __ http://userweb.kernel.org/~akpm/mmotm/
> >
> > and will soon be available at
> >
> > __ git://zen-kernel.org/kernel/mmotm.git
> >
> 
> The readme in [1] lists a wrong browseable GIT-repo URL:
> 
> "Alternatively, these patches are available in a git repository at
> 
> git:	git://zen-kernel.org/kernel/mmotm.git
> gitweb:	http://git.zen-kernel.org/?p=kernel/mmotm.git;a=summary"
> 
> Correct would be [2]:
> 
> gitweb: http://git.zen-kernel.org/mmotm/

hm, thanks.  The darn thing keeps moving around.

> > It contains the following patches against 2.6.37-rc7:
> >
> [...]
> > linux-next-git-rejects.patch
> 
> Hm, the content of this patch looks a bit strange.
> Is that a post-cleanup patch to linux-next merge?

Yes.  It's caused by skew between Linus's tree and linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
