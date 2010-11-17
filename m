Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9C22B6B00C7
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 06:16:00 -0500 (EST)
Received: by iwn5 with SMTP id 5so26079iwn.14
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 03:15:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=6RtPDnZZa=jrcciB1zHQMiB3LnouBw3G2OyaK@mail.gmail.com>
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com>
	<877hgmr72o.fsf@gmail.com>
	<20101114140920.E013.A69D9226@jp.fujitsu.com>
	<AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
	<1289810825.2109.469.camel@laptop>
	<AANLkTikibS1fDuk67RHk4SU14pJ9nPdodWba1T3Z_pWE@mail.gmail.com>
	<4CE14848.2060805@redhat.com>
	<AANLkTi=6RtPDnZZa=jrcciB1zHQMiB3LnouBw3G2OyaK@mail.gmail.com>
Date: Wed, 17 Nov 2010 20:15:41 +0900
Message-ID: <AANLkTimjfbMrNii-ps17QmEc0prBwnxwR1LYcid_ej+k@mail.gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 7:16 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Mon, Nov 15, 2010 at 11:48 PM, Rik van Riel <riel@redhat.com> wrote:
>> On 11/15/2010 04:05 AM, Minchan Kim wrote:
>>>
>>> On Mon, Nov 15, 2010 at 5:47 PM, Peter Zijlstra<peterz@infradead.org>
>>> =A0wrote:
>>>>
>>>> On Mon, 2010-11-15 at 15:07 +0900, Minchan Kim wrote:
>>
>>>>> I wonder what's the problem in Peter's patch 'drop behind'.
>>>>> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.ht=
ml
>>>>>
>>>>> Could anyone tell me why it can't accept upstream?
>>>>
>>>> Read the thread, its quite clear nobody got convinced it was a good id=
ea
>>>> and wanted to fix the use-once policy, then Rik rewrote all of
>>>> page-reclaim.
>>>>
>>>
>>> Thanks for the information.
>>> I hope this is a chance to rethink about it.
>>> Rik, Could you give us to any comment about this idea?
>
>
> Sorry for late reply, Rik.
>
>> At the time, there were all kinds of general problems
>> in page reclaim that all needed to be fixed. =A0Peter's
>> patch was mostly a band-aid for streaming IO.
>>
>> However, now that most of the other page reclaim problems
>> seem to have been resolved, it would be worthwhile to test
>> whether Peter's drop-behind approach gives an additional
>> improvement.
>
> Okay. I will have a time to make the workload for testing.
>
>>
>> I could see it help by getting rid of already-read pages
>> earlier, leaving more space for read-ahead data.
>
> Yes. Peter's logic breaks demotion if the page is in active list.
> But I think if it's just active page like rsync's two touch, we have
> to move tail of inactive although it's in active list.
> I will look into this, too.

Most important thing is how to know it's real working set or just
trick by two touch.
If it's very hard, recent Mandeep's patch can be a another solution.
http://thread.gmane.org/gmane.linux.kernel.mm/54572
I will try it, too.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
