Date: Sat, 24 Mar 2007 07:57:52 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [patch] rfc: introduce /dev/hugetlb
Message-ID: <20070324065752.GA13810@uranus.ravnborg.org>
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com> <20070323205810.3860886d.akpm@linux-foundation.org> <29495f1d0703232232o3e436c62lddccc82c4dd17b51@mail.gmail.com> <20070323221225.bdadae16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070323221225.bdadae16.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 
> But for non-programming reasons, we're just not there yet: people want to
> program direct to the kernel interfaces simply because of the
> distribution/coordination problems with libraries.  It would be nice to fix
> that problem.

What is then needed to get a small subset of user-space in the kernel-development cycle?
Maybe a topic worth to take up at LKS...

The build system is anyway ready but that the smallest issue of all :-(

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
