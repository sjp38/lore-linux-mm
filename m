Date: Wed, 30 Apr 2003 23:31:43 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [BUG] 2.5.68-mm2 and list.h
Message-Id: <20030430233143.575d7af1.akpm@digeo.com>
In-Reply-To: <873cjznq7v.fsf@lapper.ihatent.com>
References: <20030423012046.0535e4fd.akpm@digeo.com>
	<873cjznq7v.fsf@lapper.ihatent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Hoogerhuis <alexh@ihatent.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Hoogerhuis <alexh@ihatent.com> wrote:
>
> kernel BUG at include/linux/list.h:140!
> Call Trace:
>  [<c019e462>] devfs_d_revalidate_wait+0x181/0x18d

Yes.  Apparently, devfs has some programming flaws.


For now, please just delete the new debug tests in
include/linux/list.h:list_del():

#include <linux/kernel.h>       /* BUG_ON */
static inline void list_del(struct list_head *entry)
{
	BUG_ON(entry->prev->next != entry);
	BUG_ON(entry->next->prev != entry);
	__list_del(entry->prev, entry->next);
}

Those BUG_ON's.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
