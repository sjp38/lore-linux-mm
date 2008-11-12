Message-ID: <491AAA84.5040801@redhat.com>
Date: Wed, 12 Nov 2008 12:05:56 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>	<1226409701-14831-2-git-send-email-ieidus@redhat.com>	<1226409701-14831-3-git-send-email-ieidus@redhat.com>	<20081111114555.eb808843.akpm@linux-foundation.org>	<4919F1C0.2050009@redhat.com>	<Pine.LNX.4.64.0811111520590.27767@quilx.com>	<4919F7EE.3070501@redhat.com>	<Pine.LNX.4.64.0811111527500.27767@quilx.com>	<20081111222421.GL10818@random.random> <20081112111931.0e40c27d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112111931.0e40c27d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Can I make a question ? (I'm working for memory cgroup.)
>
> Now, we do charge to anonymous page when
>   - charge(+1) when it's mapped firstly (mapcount 0->1)
>   - uncharge(-1) it's fully unmapped (mapcount 1->0) vir page_remove_rmap().
>
> My quesion is
>  - PageKSM pages are not necessary to be tracked by memory cgroup ?
>  - Can we know that "the page is just replaced and we don't necessary to do
>    charge/uncharge".
>  - annonymous page from KSM is worth to be tracked by memory cgroup ?
>    (IOW, it's on LRU and can be swapped-out ?)
>   

My feeling is that shared pages should be accounted as if they were not 
shared; that is, a share page should be accounted for each process that 
shares it.  Perhaps sharing within a cgroup should be counted as 1 page 
for all the ptes pointing to it.


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
