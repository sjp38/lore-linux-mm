Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA01934
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 00:33:01 -0800 (PST)
Date: Wed, 26 Feb 2003 00:33:34 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Silly question: How to map a user space page in kernel space?
Message-Id: <20030226003334.7e85d5b2.akpm@digeo.com>
In-Reply-To: <9860000.1046238956@[10.10.2.4]>
References: <A46BBDB345A7D5118EC90002A5072C780A7D57E6@orsmsx116.jf.intel.com>
	<9860000.1046238956@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: inaky.perez-gonzalez@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> But be aware that pagefaulting inside kmap_atomic is bad - you can get
> blocked and rescheduled, so touching user pages, etc is dangerous.

That's true in 2.4.  In 2.5 a copy_foo_user() inside kmap_atomic()
will just return a short copy while remaining atomic.

See mm/filemap.c:filemap_copy_from_user()
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
