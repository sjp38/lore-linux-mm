Subject: Re: How best to bypass the page cache from within a kernel module?
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44L0.0309171402370.1171-100000@ida.rowland.org>
References: <Pine.LNX.4.44L0.0309171402370.1171-100000@ida.rowland.org>
Content-Type: text/plain
Message-Id: <1063827869.13097.124.camel@nighthawk>
Mime-Version: 1.0
Date: 17 Sep 2003 12:44:29 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2003-09-17 at 11:24, Alan Stern wrote:
> However, all that seems rather roundabout.  An equally acceptable solution 
> would be simply to invalidate all the entries in the page cache referring 
> to my file, so that reads would be forced to go to the drive.  Can anyone 
> tell me how to do that?

Whatever you're trying to do, you probably shouldn't be doing it in the
kernel to begin with.  Do it from userspace, it will save you a lot of
pain.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
