Subject: Re: Active Memory Defragmentation: Our implementation & problems
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040204065717.EFB277049E@sv1.valinux.co.jp>
References: <20040204050915.59866.qmail@web9704.mail.yahoo.com>
	 <1075874074.14153.159.camel@nighthawk>
	 <20040204065717.EFB277049E@sv1.valinux.co.jp>
Content-Type: text/plain
Message-Id: <1075878652.14155.416.camel@nighthawk>
Mime-Version: 1.0
Date: 03 Feb 2004 23:10:52 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Alok Mooley <rangdi@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-02-03 at 22:57, IWAMOTO Toshihiro wrote:
> At 03 Feb 2004 21:54:34 -0800,
> Dave Hansen wrote:
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

remap_onepage() is quite a function.  300 lines.  It sure does cover a
lot of ground. :)

Defragmentation is a bit easier than removal because it isn't as
mandatory.  Instead of having to worry about waiting on things like
writeback, the defrag code can just bail.  

--dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
