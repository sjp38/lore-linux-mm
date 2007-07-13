Message-ID: <46979C4E.6000205@oracle.com>
Date: Fri, 13 Jul 2007 08:37:50 -0700
From: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] do not limit locked memory when RLIMIT_MEMLOCK is RLIM_INFINITY
References: <4692D9E0.1000308@oracle.com> <20070713004408.b7162501.akpm@linux-foundation.org>
In-Reply-To: <20070713004408.b7162501.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave McCracken <dave.mccracken@oracle.com>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> OK.  Seems like a nasty bug if one happens to want to do that.  Should we
> backport this into 2.6.22.x?
> 

Yes, please.  Do you need me to do anything for that?

Thanks,
Herbert.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
