Received: by nproxy.gmail.com with SMTP id l35so52797nfa
        for <linux-mm@kvack.org>; Wed, 25 Jan 2006 23:30:16 -0800 (PST)
Message-ID: <84144f020601252330k61789482m25a4316c2c254065@mail.gmail.com>
Date: Thu, 26 Jan 2006 09:30:16 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 6/9] mempool - Update kzalloc mempool users
In-Reply-To: <1138218014.2092.6.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060125161321.647368000@localhost.localdomain>
	 <1138218014.2092.6.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: colpatch@us.ibm.com
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 1/25/06, Matthew Dobson <colpatch@us.ibm.com> wrote:
> plain text document attachment (critical_mempools)
> Fixup existing mempool users to use the new mempool API, part 3.
>
> This mempool users which are basically just wrappers around kzalloc().  To do
> this we create a new function, kzalloc_node() and change all the old mempool
> allocators which were calling kzalloc() to now call kzalloc_node().

The slab bits look good to me. You might have some rediffing to do
because -mm has quite a bit of slab patches in it.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

                               Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
