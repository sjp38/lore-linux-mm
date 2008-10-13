Message-ID: <48F3765A.2010301@linux-foundation.org>
Date: Mon, 13 Oct 2008 09:24:58 -0700
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, penberg@cs.helsinki.fi, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:
> I think it's wrong to unhash dentries while they are possibly still
> being used.  You can do the shrink_dcache_parent() here, but should
> leave the unhashing to be done by prune_one_dentry(), after it's been
> checked that there are no other users of the dentry.
>
>   
d_invalidate() calls shrink_dcache_parent() as needed and will fail if 
there are other users of the dentry.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
