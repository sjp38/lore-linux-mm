From: Seth Chandler <sethbc@gentoo.org>
Reply-To: sethbc@gentoo.org
Subject: Re: 2.5.65-mm3
Date: Fri, 21 Mar 2003 15:15:07 -0500
References: <20030320235821.1e4ff308.akpm@digeo.com>
In-Reply-To: <20030320235821.1e4ff308.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200303211515.07134.sethbc@gentoo.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew,

I'm getting some (sort of) random NFS Auth errors with -mm2 and -mm3.  
Sometimes the directories i export get exported read only, so i can't edit 
them on my nfs clients.  

When i'm running 2.5.65 from BK, the problem doesn't exist, its only when i 
switch to the -mm branch it manifests itself.  I was going to back out the 
nfs patches, and see if i could find the culprit....


thanks,

seth
On Friday 21 March 2003 02:58, Andrew Morton wrote:
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.65/2.5.65-mm3/
>
> Will appear later at:
>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.65/2.5.65
>-mm3/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
