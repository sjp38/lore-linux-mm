Date: Fri, 4 Apr 2003 17:29:32 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <20030404161457.GE993@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0304041725240.1970-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, Dave McCracken <dmccr@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Apr 2003, William Lee Irwin III wrote:
> 
> Hmm, aren't the file offset calculations wrong for sys_remap_file_pages()
> even before objrmap?

Yes - objrmap merely makes it difficult to find the missed pages later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
