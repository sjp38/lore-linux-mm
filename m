Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 37EAD6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 07:53:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w12so12336474wmf.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 04:53:01 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id e83si2629494wmi.72.2016.09.09.04.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 04:52:59 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id w12so2411364wmf.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 04:52:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160909104637.2580-1-colin.king@canonical.com>
References: <20160909104637.2580-1-colin.king@canonical.com>
From: Alexey Klimov <klimov.linux@gmail.com>
Date: Fri, 9 Sep 2016 12:52:58 +0100
Message-ID: <CALW4P+K_ULv97bf3VVoFVwivcB7G2MxWx5P4S4hcxdnypsRpXA@mail.gmail.com>
Subject: Re: [PATCH] mm: mlock: check if vma is locked using & instead of && operator
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin King <colin.king@canonical.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Simon Guo <wei.guo.simon@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Colin,

On Fri, Sep 9, 2016 at 11:46 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> The check to see if a vma is locked is using the operator && and
> should be using the bitwise operator & to see if the VM_LOCKED bit
> is set. Fix this to use & instead.
>
> Fixes: ae38c3be005ee ("mm: mlock: check against vma for actual mlock() size")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  mm/mlock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/mlock.c b/mm/mlock.c
> index fafbb78..f5b1d07 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -643,7 +643,7 @@ static int count_mm_mlocked_page_nr(struct mm_struct *mm,
>         for (; vma ; vma = vma->vm_next) {
>                 if (start + len <=  vma->vm_start)
>                         break;
> -               if (vma->vm_flags && VM_LOCKED) {
> +               if (vma->vm_flags & VM_LOCKED) {
>                         if (start > vma->vm_start)
>                                 count -= (start - vma->vm_start);
>                         if (start + len < vma->vm_end) {
> --

I think it was already addressed in [1] by Simon Guo.

[1] http://www.spinics.net/lists/linux-mm/msg113228.html

-- 
Best regards,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
