Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id EC9BC6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 01:27:56 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1933771ghr.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 22:27:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FEBE646.5090801@jp.fujitsu.com>
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9DB1.7010303@jp.fujitsu.com>
 <4FEAC916.7030506@cn.fujitsu.com> <4FEBE646.5090801@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 01:27:35 -0400
Message-ID: <CAHGf_=rzRthh+hpKWAVF9OyL+P_NhFw4y+W-tF3j0zB8pr0QjA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/12] memory-hogplug : check memory offline in offline_pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

On Thu, Jun 28, 2012 at 1:06 AM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> Hi Wen,
>
> 2012/06/27 17:49, Wen Congyang wrote:
>> At 06/27/2012 01:44 PM, Yasuaki Ishimatsu Wrote:
>>> When offline_pages() is called to offlined memory, the function fails since
>>> all memory has been offlined. In this case, the function should succeed.
>>> The patch adds the check function into offline_pages().
>>
>> You miss such case: some pages are online, while some pages are offline.
>> offline_pages() will fail too in such case.
>
> You are right. But current code fails, when the function is called to offline
> memory. In this case, the function should succeed. So the patch confirms
> whether the memory was offlined or not. And if memory has already been
> offlined, offline_pages return 0.

Can you please explain why the caller can't check it? I hope to avoid
an ignorance
as far as we can.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
