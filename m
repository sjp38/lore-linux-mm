Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56CAAC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 17:20:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E725F20578
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 17:20:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="3ZJfB/Dq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E725F20578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F78B8E0003; Wed, 16 Jan 2019 12:20:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 781A68E0002; Wed, 16 Jan 2019 12:20:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64A648E0003; Wed, 16 Jan 2019 12:20:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9C228E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:20:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so2586182edm.18
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:20:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=dhoqJQ5hNXDFZwsw88B+jCdN32qe+6XnxaVri7EgCZI=;
        b=KPmzP62YelO55TeAOTs44S8CgQUw6BsIDOTdXtrH1+2ADAZXSBVLVYvG6xD8l4uw7l
         aLPOOQJpFBDT0HilcMtY+qovJEz34tcBsQjs8UDhwhthbLJNNqwM81UGIEWu0u9EVCB6
         jYhYjATNLpGx71FziEydFUxlJVfKpU3htit8abVQauh2/CFZfNDfmYWBfBBfr4sUwF3Z
         4Whpo60xeygzAGQC/2+MHx9aKYwKLaqhn2ZAITiy35i5WIm+B1FB9p3t7K/7rFgJBtMh
         3l69qXFJHLBqjOPR3d79vgtcs55xn0ruTuN/5/2epXm0VH8mAnvwcgKTN9+yIWGe+6L/
         Gdwg==
X-Gm-Message-State: AJcUukcU8Adlt0/mWGktKKtdlYptyYIWUqT5jFPUfwJGFGxYEiwdBerk
	y+FEpC85CNRhpy9f0JQ6mNLbCgCrC2fN9s0bkgiaIPCoMWmeJ1zv2zvR9i5tFSeG+EYmDyaAPHZ
	U5S6uZK1hcYUl3IQhd3BKCTQ453Wqnxa5t1eT2Vy7fLs809rZORwsJAN1CWYZCAKsDQ==
X-Received: by 2002:a17:906:7a18:: with SMTP id d24-v6mr7638839ejo.16.1547659234228;
        Wed, 16 Jan 2019 09:20:34 -0800 (PST)
X-Google-Smtp-Source: ALg8bN59DNKOeV7DyvvfYbBz4eN/olsD3V3hKfjBomLspPzIUsfy/QwR1Fu3FcL7oYAJNtDcbYdw
X-Received: by 2002:a17:906:7a18:: with SMTP id d24-v6mr7638792ejo.16.1547659233195;
        Wed, 16 Jan 2019 09:20:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547659233; cv=none;
        d=google.com; s=arc-20160816;
        b=kFnTNwqFDFeWFauqgRpCRBXM9TgmdVLWzRjcXGe2jpcP8MehzWM2ksNjS9m+KobW0x
         x2G5a5vZBShHmJW3XJd5QrW9dlIjZLuNPG69ZsU/g30nNrAo68BrCedoTQCsf+hmpHuE
         BC+Yj+MJG7OW43DXTp0hYs9NzTut3V4WJX4tZFExZAb2GxjN047h91YkIsLcirDklsBV
         AjrZDMydAN+pY77nx/oXdiJ8sYiztjjqy+J8Ao76J2fcem1mehBQd1K7CM2u/zSugul4
         YZu/+1/E7BBfrGdGSRsUiGV+uZoMYfjJ1eC8YlcWrfiTIwyu2L6YSYgwkWmvaJa3Y2MV
         eWyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject
         :dkim-signature;
        bh=dhoqJQ5hNXDFZwsw88B+jCdN32qe+6XnxaVri7EgCZI=;
        b=pL23gN6SDqQ0+Oc2VmFQVMXRJtVATuPOwV7hgkxGy5xJenUArR5du5hb92S05AYbwD
         wx/ObFxw+XW7I5dtBsm2qO9YnxQSlHtUVhG+4HXhHOTcZ3PJzp25Y4qgkMPxZ9vnkUG6
         mfyEPWj2tAb7ssEieKxqleVpCGjPj1TfG7Ak7oW7m854lhETnsfIwWRq+NKcIcRKNj5x
         CHtu+11AtrU7htUPUli/eg4HB89QSBrYg9a8i+TzKY+HtE8xi0KIfw6+5V1jCsl3U+ag
         lt4F0ubdag40gjErhZT9jAvnROGKXOsT4XOoLiLTft7dgiG68xZeswGwvbYBmoBelgdU
         ZxgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="3ZJfB/Dq";
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id cc8-v6si3710090ejb.248.2019.01.16.09.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:20:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="3ZJfB/Dq";
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0GHEGt9159725;
	Wed, 16 Jan 2019 17:20:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=dhoqJQ5hNXDFZwsw88B+jCdN32qe+6XnxaVri7EgCZI=;
 b=3ZJfB/DquttKIXUM9jBCkn2TOU01jkE5R6+9Kl15HsHD35CvgTZ5YL+pk4yu8r3+JB0o
 i199h9d9opZl3jEMevcKAxXv4L3R2HEFa7sTFKBhM1VmDRTOr2YZG8qb4JswizDDv7Iz
 aloKXALPpwiGmhn6wQYkaMwsC/KWOa8lfZeEjrFIWE2vrzl6JBxQuqNrYe9MtY7qo5yJ
 ILIPN/+MJUm/UyEqV5XNr88IHHfyXk/9QDjAQiu5G6SuvJSBrtjvZ/1mZgLaKS+tshCb
 t5cSUY/1bbnWRB9V8VYwD3SeE5Q/o7NMcqXudPTc45fjXNl/doe4ebQwCt64g67WAaLM YA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2pybjnua3a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 16 Jan 2019 17:20:26 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0GHKKg7012294
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 16 Jan 2019 17:20:20 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0GHKJ1X020406;
	Wed, 16 Jan 2019 17:20:19 GMT
Received: from [10.159.231.6] (/10.159.231.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 16 Jan 2019 09:20:19 -0800
Subject: Re: [PATCH] mm: hwpoison: use do_send_sig_info() instead of
 force_sig() (Re: PMEM error-handling forces SIGKILL causes kernel panic)
To: Dan Williams <dan.j.williams@intel.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <e3c4c0e0-1434-4353-b893-2973c04e7ff7@oracle.com>
 <CAPcyv4j67n6H7hD6haXJqysbaauci4usuuj5c+JQ7VQBGngO1Q@mail.gmail.com>
 <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
 <20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp>
 <CAPcyv4jnHqDp7s1SdqHePms2Z-8d0zk-+6meqKeMQUNArxHb_w@mail.gmail.com>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <bdf211ba-1429-fadb-9c0a-aa6dd52d48ab@oracle.com>
Date: Wed, 16 Jan 2019 09:20:12 -0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jnHqDp7s1SdqHePms2Z-8d0zk-+6meqKeMQUNArxHb_w@mail.gmail.com>
Content-Type: multipart/alternative;
 boundary="------------0561E387B57A6939D37E0BC0"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9138 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901160139
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116172012.28kk7ZGvq8kQzXMafOJKCbyL1v5dt2CArkSeTYVT1hY@z>

This is a multi-part message in MIME format.
--------------0561E387B57A6939D37E0BC0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit


On 1/16/2019 8:55 AM, Dan Williams wrote:
> On Wed, Jan 16, 2019 at 1:33 AM Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
>> [ CCed Andrew and linux-mm ]
>>
>> On Fri, Jan 11, 2019 at 08:14:02AM +0000, Horiguchi Naoya(堀口 直也) wrote:
>>> Hi Dan, Jane,
>>>
>>> Thanks for the report.
>>>
>>> On Wed, Jan 09, 2019 at 03:49:32PM -0800, Dan Williams wrote:
>>>> [ switch to text mail, add lkml and Naoya ]
>>>>
>>>> On Wed, Jan 9, 2019 at 12:19 PM Jane Chu <jane.chu@oracle.com> wrote:
>>> ...
>>>>> 3. The hardware consists the latest revision CPU and Intel NVDIMM, we suspected
>>>>>     the CPU faulty because it generated MCE over PMEM UE in a unlikely high
>>>>>     rate for any reasonable NVDIMM (like a few per 24hours).
>>>>>
>>>>> After swapping the CPU, the problem stopped reproducing.
>>>>>
>>>>> But one could argue that perhaps the faulty CPU exposed a small race window
>>>>> from collect_procs() to unmap_mapping_range() and to kill_procs(), hence
>>>>> caught the kernel  PMEM error handler off guard.
>>>> There's definitely a race, and the implementation is buggy as can be
>>>> seen in __exit_signal:
>>>>
>>>>          sighand = rcu_dereference_check(tsk->sighand,
>>>>                                          lockdep_tasklist_lock_is_held());
>>>>          spin_lock(&sighand->siglock);
>>>>
>>>> ...the memory-failure path needs to hold the proper locks before it
>>>> can assume that de-referencing tsk->sighand is valid.
>>>>
>>>>> Also note, the same workload on the same faulty CPU were run on Linux prior to
>>>>> the 4.19 PMEM error handling and did not encounter kernel crash, probably because
>>>>> the prior HWPOISON handler did not force SIGKILL?
>>>> Before 4.19 this test should result in a machine-check reboot, not
>>>> much better than a kernel crash.
>>>>
>>>>> Should we not to force the SIGKILL, or find a way to close the race window?
>>>> The race should be closed by holding the proper tasklist and rcu read lock(s).
>>> This reasoning and proposal sound right to me. I'm trying to reproduce
>>> this race (for non-pmem case,) but no luck for now. I'll investigate more.
>> I wrote/tested a patch for this issue.
>> I think that switching signal API effectively does proper locking.
>>
>> Thanks,
>> Naoya Horiguchi
>> ---
>>  From 16dbf6105ff4831f73276d79d5df238ab467de76 Mon Sep 17 00:00:00 2001
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Date: Wed, 16 Jan 2019 16:59:27 +0900
>> Subject: [PATCH] mm: hwpoison: use do_send_sig_info() instead of force_sig()
>>
>> Currently memory_failure() is racy against process's exiting,
>> which results in kernel crash by null pointer dereference.
>>
>> The root cause is that memory_failure() uses force_sig() to forcibly
>> kill asynchronous (meaning not in the current context) processes.  As
>> discussed in thread https://lkml.org/lkml/2010/6/8/236 years ago for
>> OOM fixes, this is not a right thing to do.  OOM solves this issue by
>> using do_send_sig_info() as done in commit d2d393099de2 ("signal:
>> oom_kill_task: use SEND_SIG_FORCED instead of force_sig()"), so this
>> patch is suggesting to do the same for hwpoison.  do_send_sig_info()
>> properly accesses to siglock with lock_task_sighand(), so is free from
>> the reported race.
>>
>> I confirmed that the reported bug reproduces with inserting some delay
>> in kill_procs(), and it never reproduces with this patch.
>>
>> Note that memory_failure() can send another type of signal using
>> force_sig_mceerr(), and the reported race shouldn't happen on it
>> because force_sig_mceerr() is called only for synchronous processes
>> (i.e. BUS_MCEERR_AR happens only when some process accesses to the
>> corrupted memory.)
>>
>> Reported-by: Jane Chu <jane.chu@oracle.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> ---
> Looks good to me.
>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>
> ...but it would still be good to get a Tested-by from Jane.

Sure, will let you know how the test goes.

Thanks!
-jane


--------------0561E387B57A6939D37E0BC0
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    <div class="moz-cite-prefix">On 1/16/2019 8:55 AM, Dan Williams
      wrote:<br>
    </div>
    <blockquote type="cite"
cite="mid:CAPcyv4jnHqDp7s1SdqHePms2Z-8d0zk-+6meqKeMQUNArxHb_w@mail.gmail.com">
      <pre class="moz-quote-pre" wrap="">On Wed, Jan 16, 2019 at 1:33 AM Naoya Horiguchi
<a class="moz-txt-link-rfc2396E" href="mailto:n-horiguchi@ah.jp.nec.com">&lt;n-horiguchi@ah.jp.nec.com&gt;</a> wrote:
</pre>
      <blockquote type="cite">
        <pre class="moz-quote-pre" wrap="">
[ CCed Andrew and linux-mm ]

On Fri, Jan 11, 2019 at 08:14:02AM +0000, Horiguchi Naoya(堀口 直也) wrote:
</pre>
        <blockquote type="cite">
          <pre class="moz-quote-pre" wrap="">Hi Dan, Jane,

Thanks for the report.

On Wed, Jan 09, 2019 at 03:49:32PM -0800, Dan Williams wrote:
</pre>
          <blockquote type="cite">
            <pre class="moz-quote-pre" wrap="">[ switch to text mail, add lkml and Naoya ]

On Wed, Jan 9, 2019 at 12:19 PM Jane Chu <a class="moz-txt-link-rfc2396E" href="mailto:jane.chu@oracle.com">&lt;jane.chu@oracle.com&gt;</a> wrote:
</pre>
          </blockquote>
          <pre class="moz-quote-pre" wrap="">...
</pre>
          <blockquote type="cite">
            <blockquote type="cite">
              <pre class="moz-quote-pre" wrap="">3. The hardware consists the latest revision CPU and Intel NVDIMM, we suspected
   the CPU faulty because it generated MCE over PMEM UE in a unlikely high
   rate for any reasonable NVDIMM (like a few per 24hours).

After swapping the CPU, the problem stopped reproducing.

But one could argue that perhaps the faulty CPU exposed a small race window
from collect_procs() to unmap_mapping_range() and to kill_procs(), hence
caught the kernel  PMEM error handler off guard.
</pre>
            </blockquote>
            <pre class="moz-quote-pre" wrap="">
There's definitely a race, and the implementation is buggy as can be
seen in __exit_signal:

        sighand = rcu_dereference_check(tsk-&gt;sighand,
                                        lockdep_tasklist_lock_is_held());
        spin_lock(&amp;sighand-&gt;siglock);

...the memory-failure path needs to hold the proper locks before it
can assume that de-referencing tsk-&gt;sighand is valid.

</pre>
            <blockquote type="cite">
              <pre class="moz-quote-pre" wrap="">Also note, the same workload on the same faulty CPU were run on Linux prior to
the 4.19 PMEM error handling and did not encounter kernel crash, probably because
the prior HWPOISON handler did not force SIGKILL?
</pre>
            </blockquote>
            <pre class="moz-quote-pre" wrap="">
Before 4.19 this test should result in a machine-check reboot, not
much better than a kernel crash.

</pre>
            <blockquote type="cite">
              <pre class="moz-quote-pre" wrap="">Should we not to force the SIGKILL, or find a way to close the race window?
</pre>
            </blockquote>
            <pre class="moz-quote-pre" wrap="">
The race should be closed by holding the proper tasklist and rcu read lock(s).
</pre>
          </blockquote>
          <pre class="moz-quote-pre" wrap="">
This reasoning and proposal sound right to me. I'm trying to reproduce
this race (for non-pmem case,) but no luck for now. I'll investigate more.
</pre>
        </blockquote>
        <pre class="moz-quote-pre" wrap="">
I wrote/tested a patch for this issue.
I think that switching signal API effectively does proper locking.

Thanks,
Naoya Horiguchi
---
From 16dbf6105ff4831f73276d79d5df238ab467de76 Mon Sep 17 00:00:00 2001
From: Naoya Horiguchi <a class="moz-txt-link-rfc2396E" href="mailto:n-horiguchi@ah.jp.nec.com">&lt;n-horiguchi@ah.jp.nec.com&gt;</a>
Date: Wed, 16 Jan 2019 16:59:27 +0900
Subject: [PATCH] mm: hwpoison: use do_send_sig_info() instead of force_sig()

Currently memory_failure() is racy against process's exiting,
which results in kernel crash by null pointer dereference.

The root cause is that memory_failure() uses force_sig() to forcibly
kill asynchronous (meaning not in the current context) processes.  As
discussed in thread <a class="moz-txt-link-freetext" href="https://lkml.org/lkml/2010/6/8/236">https://lkml.org/lkml/2010/6/8/236</a> years ago for
OOM fixes, this is not a right thing to do.  OOM solves this issue by
using do_send_sig_info() as done in commit d2d393099de2 ("signal:
oom_kill_task: use SEND_SIG_FORCED instead of force_sig()"), so this
patch is suggesting to do the same for hwpoison.  do_send_sig_info()
properly accesses to siglock with lock_task_sighand(), so is free from
the reported race.

I confirmed that the reported bug reproduces with inserting some delay
in kill_procs(), and it never reproduces with this patch.

Note that memory_failure() can send another type of signal using
force_sig_mceerr(), and the reported race shouldn't happen on it
because force_sig_mceerr() is called only for synchronous processes
(i.e. BUS_MCEERR_AR happens only when some process accesses to the
corrupted memory.)

Reported-by: Jane Chu <a class="moz-txt-link-rfc2396E" href="mailto:jane.chu@oracle.com">&lt;jane.chu@oracle.com&gt;</a>
Cc: Dan Williams <a class="moz-txt-link-rfc2396E" href="mailto:dan.j.williams@intel.com">&lt;dan.j.williams@intel.com&gt;</a>
Cc: <a class="moz-txt-link-abbreviated" href="mailto:stable@vger.kernel.org">stable@vger.kernel.org</a>
Signed-off-by: Naoya Horiguchi <a class="moz-txt-link-rfc2396E" href="mailto:n-horiguchi@ah.jp.nec.com">&lt;n-horiguchi@ah.jp.nec.com&gt;</a>
---
</pre>
      </blockquote>
      <pre class="moz-quote-pre" wrap="">
Looks good to me.

Reviewed-by: Dan Williams <a class="moz-txt-link-rfc2396E" href="mailto:dan.j.williams@intel.com">&lt;dan.j.williams@intel.com&gt;</a>

...but it would still be good to get a Tested-by from Jane.</pre>
    </blockquote>
    <pre>Sure, will let you know how the test goes.

Thanks!
-jane
</pre>
    <blockquote type="cite"
cite="mid:CAPcyv4jnHqDp7s1SdqHePms2Z-8d0zk-+6meqKeMQUNArxHb_w@mail.gmail.com">
      <pre class="moz-quote-pre" wrap="">
</pre>
    </blockquote>
  </body>
</html>

--------------0561E387B57A6939D37E0BC0--

