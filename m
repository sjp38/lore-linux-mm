Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 3A1A06B005D
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 19:17:22 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so4819779oag.14
        for <linux-mm@kvack.org>; Sat, 13 Oct 2012 16:17:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5077D353.3010708@jp.fujitsu.com>
References: <5077D353.3010708@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sat, 13 Oct 2012 19:17:01 -0400
Message-ID: <CAHGf_=qX=L+Kzjez=NpHxtkSQKKAwqTQ1sYi0cn-w_Ku4jdRdg@mail.gmail.com>
Subject: Re: [PATCH] mm: cleanup register_node()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, akpm@linux-foundation.org

On Fri, Oct 12, 2012 at 4:22 AM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> register_node() is defined as extern in include/linux/node.h. But the function
> is only called from register_one_node() in driver/base/node.c.
>
> So the patch defines register_node() as static.
>
> CC: David Rientjes <rientjes@google.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
