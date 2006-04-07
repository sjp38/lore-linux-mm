Subject: Re: [Patch:003/004] wait_table and zonelist initializing for
	memory hotadd (wait_table initialization)
From: Dave Hansen <dave@sr71.net>
In-Reply-To: <20060407104859.EBED.Y-GOTO@jp.fujitsu.com>
References: <20060405195913.3C45.Y-GOTO@jp.fujitsu.com>
	 <1144361104.9731.190.camel@localhost.localdomain>
	 <20060407104859.EBED.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 06 Apr 2006 20:12:04 -0700
Message-Id: <1144379524.9731.192.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-04-07 at 12:10 +0900, Yasunori Goto wrote:
> 
> This size doesn't mean bytes. It is hash table entry size.
> So, wait_table_hash_size() or wait_table_entry_size() might be better.

wait_table_hash_nr_entries() is pretty obvious, although a bit long.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
