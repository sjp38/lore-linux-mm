Date: Wed, 16 Jan 2008 12:59:49 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: SLUB: Increasing partial pages
Message-ID: <20080116195949.GO18741@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

We tested 2.6.24-rc5 + 76be895001f2b0bee42a7685e942d3e08d5dd46c

For 2.6.24-rc5 before that patch, slub had a performance penalty of
6.19%.  With the patch, slub's performance penalty was reduced to 4.38%.
This is great progress.  Can you think of anything else worth trying?

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
