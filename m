Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 30B746B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 22:03:47 -0500 (EST)
Date: Wed, 3 Mar 2010 12:03:08 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] nommu: get_user_pages(): pin last page on non-page-aligned start
Message-ID: <20100303030308.GA29025@linux-sh.org>
References: <1267554584-24349-1-git-send-email-steve@digidescorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1267554584-24349-1-git-send-email-steve@digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 02, 2010 at 12:29:44PM -0600, Steven J. Magnani wrote:
> The noMMU version of get_user_pages() fails to pin the last page
> when the start address isn't page-aligned. The patch fixes this in a way
> that makes find_extend_vma() congruent to its MMU cousin.
> 
> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>

Looks good to me.  David?

Acked-by: Paul Mundt <lethal@linux-sh.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
