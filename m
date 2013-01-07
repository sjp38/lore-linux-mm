Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 901846B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 09:38:58 -0500 (EST)
Date: Mon, 7 Jan 2013 14:38:54 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: thp: Acquire the anon_vma rwsem for lock during split
Message-ID: <20130107143854.GH3885@suse.de>
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com>
 <535932623.34838584.1356410331076.JavaMail.root@redhat.com>
 <20130103175737.GA3885@suse.de>
 <20130104140815.GA26005@suse.de>
 <50E7BF4D.4040204@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50E7BF4D.4040204@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, hughd@google.com, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Sat, Jan 05, 2013 at 01:51:09PM +0800, Zhouping Liu wrote:
> On 01/04/2013 10:08 PM, Mel Gorman wrote:
> >Zhouping, please test this patch.
> 
> Tested it, the issue is gone with following patch.
> 
> Tested-by: Zhouping Liu <zliu@redhat.com>
> 

Super. Thanks very much for reporting and testing this quickly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
