In-Reply-To: <43385412.5080506@austin.ibm.com>
References: <4338537E.8070603@austin.ibm.com> <43385412.5080506@austin.ibm.com>
Mime-Version: 1.0 (Apple Message framework v734)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Message-Id: <21024267-29C3-4657-9C45-17D186EAD808@mac.com>
Content-Transfer-Encoding: 7bit
From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: [PATCH 1/9] add defrag flags
Date: Mon, 26 Sep 2005 20:16:03 -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sep 26, 2005, at 16:03:30, Joel Schopp wrote:
> The flags are:
> __GFP_USER, which corresponds to easily reclaimable pages
> __GFP_KERNRCLM, which corresponds to userspace pages

Uhh, call me crazy, but don't those flags look a little backwards to  
you?  Maybe it's just me, but wouldn't it make sense to expect  
__GFP_USER to be a userspace allocation and __GFP_KERNRCLM to be an  
easily reclaimable kernel page?

Cheers,
Kyle Moffett

-----BEGIN GEEK CODE BLOCK-----
Version: 3.12
GCM/CS/IT/U d- s++: a18 C++++>$ UB/L/X/*++++(+)>$ P+++(++++)>$ L++++(+ 
++) E W++(+) N+++(++) o? K? w--- O? M++ V? PS+() PE+(-) Y+ PGP+++ t+(+ 
++) 5 X R? tv-(--) b++++(++) DI+ D+ G e->++++$ h!*()>++$ r  !y?(-)
------END GEEK CODE BLOCK------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
