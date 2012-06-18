Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id B43EB6B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 18:03:56 -0400 (EDT)
Message-ID: <4FDFA59D.5020200@redhat.com>
Date: Mon, 18 Jun 2012 18:03:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 3/6] Fix the x86-64 page colouring code to take pgoff
 into account and use that code as the basis for a generic page colouring
 code.
References: <1340029878-7966-1-git-send-email-riel@redhat.com> <1340029878-7966-4-git-send-email-riel@redhat.com> <m2k3z48twb.fsf@firstfloor.org> <4FDF5B3C.1000007@redhat.com> <20120618181658.GA7190@x1.osrc.amd.com> <4FDF7B5E.301@redhat.com> <20120618203720.GA4148@liondog.tnic>
In-Reply-To: <20120618203720.GA4148@liondog.tnic>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, hnaz@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On 06/18/2012 04:37 PM, Borislav Petkov wrote:

> and your patch has some new ifs in it:
>
> @@ -386,12 +398,16 @@ void validate_mm(struct mm_struct *mm)
>   	int bug = 0;
>   	int i = 0;
>   	struct vm_area_struct *tmp = mm->mmap;
> +	unsigned long highest_address = 0;
>   	while (tmp) {
>   		if (tmp->free_gap != max_free_space(&tmp->vm_rb))
>   			printk("free space %lx, correct %lx\n", tmp->free_gap, max_free_space(&tmp->vm_rb)), bug = 1;
>
> 			^^^^^^^^^^^^^^
>
> I think this if-statement is the problem. It is not present in mainline
> but this patch doesn't add it so some patch earlier than that adds it
> which is probably in your queue?

Argh! I see the problem now.

guilt-patchbomb sent everything from my second patch onwards,
not my first patch :(

Let me resend the series properly, I have 7 patches not 6.

I am having a bad email day...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
