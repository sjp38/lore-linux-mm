Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 3D6CD6B0083
	for <linux-mm@kvack.org>; Mon,  7 May 2012 20:46:59 -0400 (EDT)
Message-ID: <4FA86CFE.5080603@kernel.org>
Date: Tue, 08 May 2012 09:46:54 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] zsmalloc: make zsmalloc portable
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-7-git-send-email-minchan@kernel.org> <4F980AFE.60901@vflare.org> <4F982862.4050302@linux.vnet.ibm.com> <4FA7E6DD.6010607@linux.vnet.ibm.com>
In-Reply-To: <4FA7E6DD.6010607@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/08/2012 12:14 AM, Seth Jennings wrote:

> On 04/25/2012 11:37 AM, Seth Jennings wrote:
> 
>> I'll apply your patch and try it out.
> 
> Sorry for taking so long.
> 
> I finally got around to testing this on an x86_64 VM and it works with
> the same performance as before and is much cleaner.  I like it.  Just

> need to expand the patch to all the arches.

> 
> I'm also interested to see if this works for ppc64.  I'm hoping to try
> it out today or tomorrow.


I will have a time to make a patch in a weekend if other urgent doesn't
catch me. :)

Seth, Thanks for the testing!

> 
> --
> Seth
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
