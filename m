Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0A7D16B01CB
	for <linux-mm@kvack.org>; Thu, 20 May 2010 09:47:58 -0400 (EDT)
Message-ID: <4BF53D8B.5090407@rsk.demon.co.uk>
Date: Thu, 20 May 2010 14:47:55 +0100
From: Richard Kennedy <richard@rsk.demon.co.uk>
MIME-Version: 1.0
Subject: Re: RFC: dirty_ratio back to 40%
References: <4BF51B0A.1050901@redhat.com> <20100520122919.GA3420@fancy-poultry.org>
In-Reply-To: <20100520122919.GA3420@fancy-poultry.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Heinz Diehl <htd@fancy-poultry.org>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, lwoodman@redhat.com
List-ID: <linux-mm.kvack.org>

On 20/05/10 13:29, Heinz Diehl wrote:
> On 20.05.2010, Larry Woodman wrote: 
> lwoodman@redhat.com
>> Increasing the dirty_ratio to 40% will regain the performance loss seen
>> in several benchmarks.  Whats everyone think about this???
> 
> These are tuneable via sysctl. What I have in my /etc/sysctl.conf is
> 
>  vm.dirty_ratio = 4
>  vm.dirty_background_ratio = 2
>  
> This writes back the data more often and frequently, thus preventing the
> system from long stalls. 
> 
> Works at least for me. AMD Quadcore, 8 GB RAM.
> 
get_dirty_limits uses a minimum vm_dirty_ratio of 5, so you can't set it
lower than that (unless you use vm_dirty_bytes).
But it's interesting that you find lowering the dirty_ratio helpful. Do
you have any benchmark results you can share?
regards
Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
