Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A3B446B13F1
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 16:40:16 -0500 (EST)
Received: by iagz16 with SMTP id z16so5233764iag.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 13:40:16 -0800 (PST)
Message-ID: <4F2B02BC.8010308@gmail.com>
Date: Thu, 02 Feb 2012 16:40:12 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RESEND][PATCH] Mark thread stack correctly in proc/<pid>/maps
References: <20120116163106.GC7180@jl-vm1.vm.bytemark.co.uk> <1326776095-2629-1-git-send-email-siddhesh.poyarekar@gmail.com> <CAAHN_R2g9zaujw30+zLf91AGDHNqE6HDc8Z4yJbrzgJcJYFkXg@mail.gmail.com>
In-Reply-To: <CAAHN_R2g9zaujw30+zLf91AGDHNqE6HDc8Z4yJbrzgJcJYFkXg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: Jamie Lokier <jamie@shareable.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

>   extern unsigned long move_page_tables(struct vm_area_struct *vma,
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 3f758c7..2f9f540 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -992,6 +992,9 @@ unsigned long do_mmap_pgoff(struct file *file,
> unsigned long addr,
>         vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
>                         mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
>
> +       if (flags&  MAP_STACK)
> +               vm_flags |= VM_STACK_FLAGS;

??
MAP_STACK doesn't mean auto stack expansion. Why do you turn on VM_GROWSDOWN?
Seems incorrect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
