Date: Wed, 04 Feb 2004 19:33:30 +0900 (JST)
Message-Id: <20040204.193330.123965914.taka@valinux.co.jp>
Subject: Re: Active Memory Defragmentation: Our implementation & problems
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20040204065717.EFB277049E@sv1.valinux.co.jp>
References: <20040204050915.59866.qmail@web9704.mail.yahoo.com>
	<1075874074.14153.159.camel@nighthawk>
	<20040204065717.EFB277049E@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: iwamoto@valinux.co.jp
Cc: haveblue@us.ibm.com, rangdi@yahoo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Hello,

> > Moving file-backed pages is mostly handled already.  You can do a
> > regular page-cache lookup with find_get_page(), make your copy,
> > invalidate the old one, then readd the new one.  The invalidation can be
> > done in the same style as shrink_list().
> 
> Actually, it is a bit more complicated.
> I have implemented similar functionality for memory hotremoval.
> 
> See my post about memory hotremoval
> http://marc.theaimsgroup.com/?l=linux-kernel&m=107354781130941&w=2
> for details.
> remap_onepage() and remapd() in the patch are the main functions.

My patch may be one of the samples.
To allocate continuous pages on demand, I used remap_onepage() to
defragment pages.

http://www.ussg.iu.edu/hypermail/linux/kernel/0401.1/0045.html

Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
