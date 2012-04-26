Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5096D6B0044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:33:39 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so1717735lbb.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 12:33:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F7F3CA9.1030500@redhat.com>
References: <1333737920-17555-1-git-send-email-yinghan@google.com>
	<4F7F3CA9.1030500@redhat.com>
Date: Thu, 26 Apr 2012 12:33:36 -0700
Message-ID: <CALWz4iyKDcrLoK4Dtnwwq6OvDAiEyb72iV6dezwKmoZWhkVDSw@mail.gmail.com>
Subject: Re: [PATCH V8] Eliminate task stack trace duplication
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, tglx@linutronix.de, x86@kernel.org

++cc x86 people which I forgot this time ..

--Ying

On Fri, Apr 6, 2012 at 11:57 AM, Rik van Riel <riel@redhat.com> wrote:
> On 04/06/2012 02:45 PM, Ying Han wrote:
>>
>> The problem with small dmesg ring buffer like 512k is that only limited
>> number
>> of task traces will be logged. Sometimes we lose important information
>> only
>> because of too many duplicated stack traces. This problem occurs when
>> dumping
>> lots of stacks in a single operation, such as sysrq-T.
>>
>> This patch tries to reduce the duplication of task stack trace in the dump
>> message by hashing the task stack. The hashtable is a 32k pre-allocated
>> buffer
>> during bootup. Each time if we find the identical task trace in the task
>> stack,
>> we dump only the pid of the task which has the task trace dumped. So it is
>> easy
>> to back track to the full stack with the pid.
>
>
>> Signed-off-by: Ying Han<yinghan@google.com>
>
>
> Acked-by: Rik van Riel <riel@redhat.com>
>
> --
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
