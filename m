Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0C63B6B0098
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 04:39:15 -0500 (EST)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100303030308.GA29025@linux-sh.org>
References: <20100303030308.GA29025@linux-sh.org> <1267554584-24349-1-git-send-email-steve@digidescorp.com>
Subject: Re: [PATCH] nommu: get_user_pages(): pin last page on non-page-aligned start
Date: Mon, 08 Mar 2010 09:38:28 +0000
Message-ID: <16242.1268041108@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: dhowells@redhat.com, "Steven J. Magnani" <steve@digidescorp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Mundt <lethal@linux-sh.org> wrote:

> > The noMMU version of get_user_pages() fails to pin the last page
> > when the start address isn't page-aligned. The patch fixes this in a way
> > that makes find_extend_vma() congruent to its MMU cousin.
> > 
> > Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
> 
> Looks good to me.  David?

I don't seem to have the original patch.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
