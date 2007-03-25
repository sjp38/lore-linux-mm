Subject: Re: [patch] rfc: introduce /dev/hugetlb
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20070323205810.3860886d.akpm@linux-foundation.org>
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
	 <20070323205810.3860886d.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Sun, 25 Mar 2007 12:22:29 +0200
Message-Id: <1174818149.1158.301.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> But libraries are hard, for a number of distributional reasons.  

I don't see why this is the case to be honest.
You can ask distros to ship your library, and if it's a sensible one,
they will. And if you can't wait, you can always bundle the library with
your application, it's really not a big deal to do that properly.

That's not a reason to make it a harder problem by tying a library to
the kernel source... in fact I know enterprise distros are more likely
to uprev a library than to uprev a kernel.... tying them together you
get the worst of both worlds....

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
