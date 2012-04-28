Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id DF2746B0081
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 15:05:00 -0400 (EDT)
Date: Sat, 28 Apr 2012 12:06:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: memblock - Handled failure of debug fs entries
 creation
Message-Id: <20120428120657.4982a248.akpm@linux-foundation.org>
In-Reply-To: <CAOJFanUu_RD2UNgFg4gNuPte+jOA95ejMtq53UCo6vLaLohmQQ@mail.gmail.com>
References: <1335383992-19419-1-git-send-email-sasikanth.v19@gmail.com>
	<20120426162108.b654a920.akpm@linux-foundation.org>
	<CAOJFanUu_RD2UNgFg4gNuPte+jOA95ejMtq53UCo6vLaLohmQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasikanth babu <sasikanth.v19@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 29 Apr 2012 00:32:26 +0530 Sasikanth babu <sasikanth.v19@gmail.com> wrote:

> > Fact is, debugfs_create_dir() and debugfs_create_file() are stupid
> > interfaces which don't provide the caller (and hence the user) with any
> > information about why they failed.  Perhaps memblock_init_debugfs()
> > should return -EWESUCK.
> >
> 
>    I'm working on a patch which address this issue. debugfs_create_XXX
> calls
>    will return proper error codes, and fixing the existing code not each
> and every part  but the code
>    which handles the values returned by debufs_create_XXX otherwise it will
> break the existing
>    functionality .

Excellent!

> (any suggestions or opinions ?)

Well, don't modify the existing interfaces: create new ones and we can
migrate gradually.  But you're probably already doing that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
