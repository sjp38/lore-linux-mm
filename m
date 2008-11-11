Message-ID: <4919FB31.7090506@redhat.com>
Date: Tue, 11 Nov 2008 23:37:53 +0200
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <20081111114555.eb808843.akpm@linux-foundation.org> <4919F1C0.2050009@redhat.com> <Pine.LNX.4.64.0811111520590.27767@quilx.com> <4919F7EE.3070501@redhat.com> <Pine.LNX.4.64.0811111527500.27767@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0811111527500.27767@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>
>
> Currently page migration assumes that the page will continue to be part
> of the existing file or anon vma.
>   

exactly, and ksm really need it to get out of the existing anon vma!

> What you want sounds like assigning a swap pte to an anonymous page? That
> way a anon page gains membership in a file backed mapping.
>
>
>   

No, i want pte that is found inside vma and point to anonymous page, 
will stop point into the anonymous page
and will point to a whole diffrent page that i chose (for ksm it is 
needed because this way we are mapping alot
of ptes into the same write_protected page and save memory)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
