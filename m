Subject: Re: Quick question
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58-035.0402232213250.18964@unix50.andrew.cmu.edu>
References: <Pine.LNX.4.58-035.0402232213250.18964@unix50.andrew.cmu.edu>
Content-Type: text/plain
Message-Id: <1077596693.8563.53.camel@nighthawk>
Mime-Version: 1.0
Date: Mon, 23 Feb 2004 20:24:53 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anand Eswaran <aeswaran@andrew.cmu.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2004-02-23 at 19:14, Anand Eswaran wrote:
>    Are there any particular flags for a page that I can use to check if a
> given page is used by the slab-allocator or not.

#define PageSlab(page)          test_bit(PG_slab, &(page)->flags)
#define SetPageSlab(page)       set_bit(PG_slab, &(page)->flags)
#define ClearPageSlab(page)     clear_bit(PG_slab, &(page)->flags)
#define TestClearPageSlab(page) test_and_clear_bit(PG_slab, &(page)->flags)
#define TestSetPageSlab(page)   test_and_set_bit(PG_slab, &(page)->flags)

-- dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
