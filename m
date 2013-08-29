Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 54A076B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 00:10:26 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id wo10so7783318obc.27
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 21:10:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <521eb73e.e3bf420a.2ad0.09c2SMTPIN_ADDED_BROKEN@mx.google.com>
References: <20130820160735.b12fe1b3dd64b4dc146d2fa0@linux-foundation.org>
	<CAE9FiQVy2uqLm2XyStYmzxSmsw7TzrB0XDhCRLymnf+L3NPxrA@mail.gmail.com>
	<52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
	<CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
	<52146c58.a3e2440a.0f5a.ffffed8dSMTPIN_ADDED_BROKEN@mx.google.com>
	<CAE9FiQVWVzO93RM_QT-Qp+5jJUEiw=5OOD_454fCjgQ5p9-b3g@mail.gmail.com>
	<521600cc.22ab440a.2703.53f1SMTPIN_ADDED_BROKEN@mx.google.com>
	<CAE9FiQXrpZU8DCFoF6NuaOoqwGFGcQfnHV7vdWWPfyAymCCGnQ@mail.gmail.com>
	<CAE9FiQU34RC+4uLpeza4PAAK-1CWu82WQ=rhaM_NNj_TVv0EMg@mail.gmail.com>
	<CAE9FiQVPmjxCzOCPQWz4=6JwzB-Vn5YMtOEd-G97SvEgoY3RQg@mail.gmail.com>
	<521eb73e.e3bf420a.2ad0.09c2SMTPIN_ADDED_BROKEN@mx.google.com>
Date: Wed, 28 Aug 2013 21:10:25 -0700
Message-ID: <CAE9FiQWV2m6MvRXFAXMYr-D0RSEj9vXiKBQhp5LmzpJFEizyww@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Aug 28, 2013 at 7:51 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> Hi Yinghai,
>>> looks like that is what is your first version did.
>>>
>>> I updated it a little bit. please check it.
>>>
>>
>>removed more lines.
>
> Thanks for your great work!
>
> The fixed patch looks good to me. If this is the last fix and I can
> ignore http://marc.info/?l=linux-mm&m=137774271220239&w=2?

Yes, you can ignore that.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
