Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 106936B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 01:33:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 29 Aug 2013 15:29:49 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 4DC852CE8059
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 15:33:05 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7T5GhB48782096
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 15:16:49 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7T5WvOq002050
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 15:32:58 +1000
Date: Thu, 29 Aug 2013 13:32:55 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/4] mm/sparse: introduce alloc_usemap_and_memmap
Message-ID: <20130829053255.GA15379@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52142ffe.84c0440a.57e5.02acSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQW1c3-d+iMebRK6JyHCpMt8mjga-TnsfTuVsC1bQZqsYA@mail.gmail.com>
 <52146c58.a3e2440a.0f5a.ffffed8dSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQVWVzO93RM_QT-Qp+5jJUEiw=5OOD_454fCjgQ5p9-b3g@mail.gmail.com>
 <521600cc.22ab440a.2703.53f1SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQXrpZU8DCFoF6NuaOoqwGFGcQfnHV7vdWWPfyAymCCGnQ@mail.gmail.com>
 <CAE9FiQU34RC+4uLpeza4PAAK-1CWu82WQ=rhaM_NNj_TVv0EMg@mail.gmail.com>
 <CAE9FiQVPmjxCzOCPQWz4=6JwzB-Vn5YMtOEd-G97SvEgoY3RQg@mail.gmail.com>
 <521eb73e.e3bf420a.2ad0.09c2SMTPIN_ADDED_BROKEN@mx.google.com>
 <CAE9FiQWV2m6MvRXFAXMYr-D0RSEj9vXiKBQhp5LmzpJFEizyww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Content-Disposition: inline
In-Reply-To: <CAE9FiQWV2m6MvRXFAXMYr-D0RSEj9vXiKBQhp5LmzpJFEizyww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 28, 2013 at 09:10:25PM -0700, Yinghai Lu wrote:
>On Wed, Aug 28, 2013 at 7:51 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>> Hi Yinghai,
>>>> looks like that is what is your first version did.
>>>>
>>>> I updated it a little bit. please check it.
>>>>
>>>
>>>removed more lines.
>>
>> Thanks for your great work!
>>
>> The fixed patch looks good to me. If this is the last fix and I can
>> ignore http://marc.info/?l=linux-mm&m=137774271220239&w=2?
>
>Yes, you can ignore that.

Thanks, a little adjustment to fix compile warning. 

>
>Yinghai

Hi Andrew,

The patch in attachment is rebased on mm-sparse-introduce-alloc_usemap_and_memmap-fix.patch,
Could you pick this one?



--ibTvN161/egqYuK8
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-sparse.patch"


--ibTvN161/egqYuK8--
