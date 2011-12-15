Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1BBDC6B004F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 13:40:44 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so3763874wgb.26
        for <linux-mm@kvack.org>; Thu, 15 Dec 2011 10:40:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201112151139.32224.ptesarik@suse.cz>
References: <201112140033.58951.ptesarik@suse.cz>
	<CAM_iQpUr3MqwWzeD4Z8KzyErEM4utT=CkpbyecPu75-QDDznHQ@mail.gmail.com>
	<201112151139.32224.ptesarik@suse.cz>
Date: Thu, 15 Dec 2011 10:40:42 -0800
Message-ID: <CAOS58YP8o9xQvZJtpEJobChhJ+pSDQ9PqDwaXFS_h+JFd65jOw@mail.gmail.com>
Subject: Re: Is per_cpu_ptr_to_phys broken?
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>, surovegin@google.com, gthelen@google.com

Hello,

> Now, per_cpu_ptr() gives the correct virtual address, but
> per_cpu_ptr_to_phys() gets the result wrong, regardless whether it thinks that
> the address is in the first chunk or not:

Yeah, that's me forgetting "+ offset_in_page()" after vmalloc page
translation, which incidentally was also discovered by surovegin last
night. It has been broken forever, by which I mean longer than six
months. I wonder why this is coming up only now. Anyways, please send
me a patch, I'll be push it mainline & to stable.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
