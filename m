Date: Tue, 25 Mar 2008 16:32:40 -0700 (PDT)
Message-Id: <20080325.163240.102401706.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <18408.59112.945786.488350@cargo.ozlabs.ibm.com>
References: <18408.29107.709577.374424@cargo.ozlabs.ibm.com>
	<20080324.211532.33163290.davem@davemloft.net>
	<18408.59112.945786.488350@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Paul Mackerras <paulus@samba.org>
Date: Tue, 25 Mar 2008 22:50:00 +1100
Return-Path: <owner-linux-mm@kvack.org>
To: paulus@samba.org
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> How do I get gcc to use hugepages, for instance?

Implementing transparent automatic usage of hugepages has been
discussed many times, it's definitely doable and other OSs have
implemented this for years.

This is what I was implying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
