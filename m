Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 0F1696B006E
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 08:40:10 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id v19so44422obq.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 05:40:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLFy5TP_xJ0GcqYdpsZ_Lj+Sf2Bfn99CqCqOv8P21N8+UA@mail.gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
	<1354810175-4338-2-git-send-email-js1304@gmail.com>
	<CAOJsxLFy5TP_xJ0GcqYdpsZ_Lj+Sf2Bfn99CqCqOv8P21N8+UA@mail.gmail.com>
Date: Fri, 7 Dec 2012 22:40:10 +0900
Message-ID: <CAAmzW4PDmL-1U6SVFohS_du-7uJngbR-4EBa4UUSWa-xs66Lmw@mail.gmail.com>
Subject: Re: [RFC PATCH 1/8] mm, vmalloc: change iterating a vmlist to find_vm_area()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Chris Metcalf <cmetcalf@tilera.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

Hello, Pekka.

2012/12/7 Pekka Enberg <penberg@kernel.org>:
> On Thu, Dec 6, 2012 at 6:09 PM, Joonsoo Kim <js1304@gmail.com> wrote:
>> The purpose of iterating a vmlist is finding vm area with specific
>> virtual address. find_vm_area() is provided for this purpose
>> and more efficient, because it uses a rbtree.
>> So change it.
>
> You no longer take the 'vmlist_lock'. This is safe, because...?

As Bob mentioned, find_vm_area() hold a 'vmap_area_lock' during
searching a area.
When we hold a 'vmap_area_lock', area can't be removed.
So this change is safe.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
