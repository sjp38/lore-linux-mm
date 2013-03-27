Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 25A886B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 16:04:41 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ef105888-1996-4c78-829a-36b84973ce65@default>
Date: Wed, 27 Mar 2013 13:04:25 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: zsmalloc zbud hybrid design discussion?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Seth and all zproject folks --

I've been giving some deep thought as to how a zpage
allocator might be designed that would incorporate the
best of both zsmalloc and zbud.

Rather than dive into coding, it occurs to me that the
best chance of success would be if all interested parties
could first discuss (on-list) and converge on a design
that we can all agree on.  If we achieve that, I don't
care who writes the code and/or gets the credit or
chooses the name.  If we can't achieve consensus, at
least it will be much clearer where our differences lie.

Any thoughts?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
