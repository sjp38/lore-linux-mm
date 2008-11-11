Date: Tue, 11 Nov 2008 11:20:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
Message-Id: <20081111112043.bf1af70e.akpm@linux-foundation.org>
In-Reply-To: <4919D7DE.4000508@redhat.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<20081111103051.979aea57.akpm@linux-foundation.org>
	<4919D7DE.4000508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008 21:07:10 +0200
Izik Eidus <ieidus@redhat.com> wrote:

> we have used KSM in production for about half year and the numbers that 
> came from our QA is:
> using KSM for desktop (KSM was tested just for windows desktop workload) 
> you can run as many as
> 52 windows xp with 1 giga ram each on server with just 16giga ram. (this 
> is more than 300% overcommit)
> the reason is that most of the kernel/dlls of this guests is shared and 
> in addition we are sharing the windows zero
> (windows keep making all its free memory as zero, so every time windows 
> release memory we take the page back to the host)
> there is slide that give this numbers you can find at:
> http://kvm.qumranet.com/kvmwiki/KvmForum2008?action=AttachFile&do=get&target=kdf2008_3.pdf 
> (slide 27)
> beside more i gave presentation about ksm that can be found at:
> http://kvm.qumranet.com/kvmwiki/KvmForum2008?action=AttachFile&do=get&target=kdf2008_12.pdf

OK, 300% isn't chicken feed.

It is quite important that information such as this be prepared, added to
the patch changelogs and maintained.  For a start, without this basic
information, there is no reason for anyone to look at any of the code!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
