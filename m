Date: Tue, 01 Mar 2005 09:09:04 +0900 (JST)
Message-Id: <20050301.090904.71101313.taka@valinux.co.jp>
Subject: Re: [PATCH] mm: memory migration: bug in touch_unmapped_address
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <422356AB.4040703@sgi.com>
References: <422356AB.4040703@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com
Cc: marcelo.tosatti@cyclades.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ray,

> Hirokazu,
> 
> The length field in the call to get_user_pages() from touch_unmapped_pages()
> is incorrectly specified in bytes, not pages.
>
> As a result of this, if you use the migration code to migrate a page, then
> subsequent pages (that are not necessarily currently allocated or mapped)
> can be allocated and mapped as a result of the migration call.

Yes, you're absolutely right.
I'll fix it soon.

> [touch_unmapped_pages() is added by the memory migration code from the memory
> hotplug patch so this is not currently part of the mainline kernel]
> 
> See attached patch for the fix.

Thank you,
Hirokazu Takahashi
   who is the person looking for new sponsors to help us to
   continue developing the memory migration feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
