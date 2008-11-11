Date: Tue, 11 Nov 2008 15:21:45 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
In-Reply-To: <4919F1C0.2050009@redhat.com>
Message-ID: <Pine.LNX.4.64.0811111520590.27767@quilx.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
 <1226409701-14831-2-git-send-email-ieidus@redhat.com>
 <1226409701-14831-3-git-send-email-ieidus@redhat.com>
 <20081111114555.eb808843.akpm@linux-foundation.org> <4919F1C0.2050009@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008, Izik Eidus wrote:

> yes but it replace it with kernel allocated page.
> > page migration already kinda does that.  Is there common ground?
> >
> >
> page migration as far as i saw cant migrate anonymous page into kernel page.
> if you want we can change page_migration to do that, but i thought you will
> rather have ksm changes separate.

What do you mean by kernel page? The kernel can allocate a page and then
point a user space pte to it. That is how page migration works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
