Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 355A66B00A6
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 16:33:44 -0500 (EST)
Date: Wed, 14 Nov 2012 13:33:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 00/11] Introduce huge zero page
Message-Id: <20121114133342.cc7bcd6e.akpm@linux-foundation.org>
In-Reply-To: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed,  7 Nov 2012 17:00:52 +0200
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Andrew, here's updated huge zero page patchset.

There is still a distinct lack of reviewed-by's and acked-by's on this
patchset.

On 13 Sep, Andrea did indicate that he "reviewed the whole patchset and
it looks fine to me".  But that information failed to make it into the
changelogs, which is bad.

I grabbed the patchset.  I might hold it over until 3.9 depending on
additional review/test feedback and upon whether Andrea can be
persuaded to take another look at it all.

I'm still a bit concerned over the possibility that some workloads will
cause a high-frequency free/alloc/memset cycle on that huge zero page. 
We'll see how it goes...

For this reason and for general ease-of-testing: can and should we add
a knob which will enable users to disable the feature at runtime?  That
way if it causes problems or if we suspect it's causing problems, we
can easily verify the theory and offer users a temporary fix.

Such a knob could be a boot-time option, but a post-boot /proc thing
would be much nicer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
