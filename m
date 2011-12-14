Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 5818B6B02FC
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 11:17:16 -0500 (EST)
Received: by yenq10 with SMTP id q10so939234yen.14
        for <linux-mm@kvack.org>; Wed, 14 Dec 2011 08:17:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201112140033.58951.ptesarik@suse.cz>
References: <201112140033.58951.ptesarik@suse.cz>
Date: Thu, 15 Dec 2011 00:17:15 +0800
Message-ID: <CAM_iQpUr3MqwWzeD4Z8KzyErEM4utT=CkpbyecPu75-QDDznHQ@mail.gmail.com>
Subject: Re: Is per_cpu_ptr_to_phys broken?
From: Cong Wang <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Tesarik <ptesarik@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>

On Wed, Dec 14, 2011 at 7:33 AM, Petr Tesarik <ptesarik@suse.cz> wrote:
> Hi folks,
>
...
>
> Now, the per_cpu_ptr_to_phys() function aligns all vmalloc addresses to a page
> boundary. This was probably right when Vivek Goyal introduced that function
> (commit 3b034b0d084221596bf35c8d893e1d4d5477b9cc), because per-cpu addresses
> were only allocated by vmalloc if booted with percpu_alloc=page, but this is
> no longer the case, because per-cpu variables are now always allocated that
> way AFAICS.
>
> So, shouldn't we add the offset within the page inside per_cpu_ptr_to_phys?
>

Hi,

Tejun already fixed this, see:

commit	a855b84c3d8c73220d4d3cd392a7bee7c83de70e
percpu: fix chunk range calculation
author	Tejun Heo <tj@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
