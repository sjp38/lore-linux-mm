Received: by ug-out-1314.google.com with SMTP id s2so1790532uge
        for <linux-mm@kvack.org>; Tue, 27 Mar 2007 01:41:34 -0700 (PDT)
Message-ID: <6d6a94c50703270141u5e59f73dj8bef0de0cfed1924@mail.gmail.com>
Date: Tue, 27 Mar 2007 16:41:33 +0800
From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [PATCH 3/3][RFC] Containers: Pagecache controller reclaim
In-Reply-To: <4608C4F6.4020407@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <45ED251C.2010400@linux.vnet.ibm.com>
	 <45ED266E.7040107@linux.vnet.ibm.com>
	 <6d6a94c50703262044q22e94538i5e79a32a82f7c926@mail.gmail.com>
	 <4608C4F6.4020407@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, ckrm-tech@lists.sourceforge.net, Balbir Singh <balbir@in.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>, devel@openvz.org, xemul@sw.ru, Paul Menage <menage@google.com>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On 3/27/07, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> wrote:
> Correct, shrink_page_list() is called from shrink_inactive_list() but
> the above code is patched in shrink_active_list().  The
> 'force_reclaim_mapped' label is from function shrink_active_list() and
> not in shrink_page_list() as it may seem in the patch file.
>
> While removing pages from active_list, we want to select only
> pagecache pages and leave the remaining in the active_list.
> page_mapped() pages are _not_ of interest to pagecache controller
> (they will be taken care by rss controller) and hence we put it back.
>  Also if the pagecache controller is below limit, no need to reclaim
> so we put back all pages and come out.

Oh, I just read the patch, not apply it to my local tree, I'm working
on 2.6.19 now.
So the question is, when vfs pagecache limit is hit, the current
implementation just reclaim few pages, so it's quite possible the
limit is hit again, and hence the reclaim code will be called again
and again, that will impact application performance.

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
