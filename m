Date: Wed, 17 Sep 2003 12:50:44 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: How best to bypass the page cache from within a kernel module?
Message-ID: <20030917195044.GH14079@holomorphy.com>
References: <Pine.LNX.4.44L0.0309171402370.1171-100000@ida.rowland.org> <1063827869.13097.124.camel@nighthawk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1063827869.13097.124.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2003-09-17 at 11:24, Alan Stern wrote:
>> However, all that seems rather roundabout.  An equally acceptable solution 
>> would be simply to invalidate all the entries in the page cache referring 
>> to my file, so that reads would be forced to go to the drive.  Can anyone 
>> tell me how to do that?

On Wed, Sep 17, 2003 at 12:44:29PM -0700, Dave Hansen wrote:
> Whatever you're trying to do, you probably shouldn't be doing it in the
> kernel to begin with.  Do it from userspace, it will save you a lot of
> pain.

If you really want to bypass the pagecache etc. entirely, use raw io and
don't even bother mounting the filesystem, and do it all from userspace.
If you need it simultaneously mounted then you're in somewhat deeper
trouble, though you can probably be rescued by nefarious means like that
bit about shooting down the pagecache so you don't have some incoherent
cache headache.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
