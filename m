Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 747C56B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 14:15:18 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2944673yen.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 11:15:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA02603.80807@openvz.org>
References: <20120430112903.14137.81692.stgit@zurg> <20120430112910.14137.28935.stgit@zurg>
 <CAHGf_=rWDMMv2dKz3paV2MnjsCNWBa2BaUTi+RnDo8DZ4zEr=g@mail.gmail.com> <4FA02603.80807@openvz.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 1 May 2012 14:14:57 -0400
Message-ID: <CAHGf_=o_R8k-ywaAodrrHcnnjad01kp1szw_AuA-5AiB19fLew@mail.gmail.com>
Subject: Re: [PATCH RFC 3/3] proc/smaps: show amount of hwpoison pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Tue, May 1, 2012 at 2:05 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> KOSAKI Motohiro wrote:
>>
>> On Mon, Apr 30, 2012 at 7:29 AM, Konstantin Khlebnikov
>> <khlebnikov@openvz.org> =A0wrote:
>>>
>>> This patch adds line "HWPoinson:<size> =A0kB" into /proc/pid/smaps if
>>> CONFIG_MEMORY_FAILURE=3Dy and some HWPoison pages were found.
>>> This may be useful for searching applications which use a broken memory=
.
>>
>>
>> I dislike "maybe useful" claim. If we don't know exact motivation of a
>> feature,
>> we can't maintain them especially when a bugfix can't avoid ABI change.
>>
>> Please write down exact use case.
>
> I don't know how to exactly use this hw-poison stuff, but smaps suppose t=
o
> export state of ptes in vma. It seems to rational to show also hw-poisone=
d
> ptes,
> since kernel has this feature and pte can be in hw-poisoned state.
>
> and now everyone can easily find them:
> # sudo grep HWPoison /proc/*/smaps

First, I don't think "we can expose it" is good reason. Second, hw-poisoned=
 mean
such process is going to be killed at next page touch. But I can't
imagine anyone can
use its information because it's racy against process kill. I think
admin should use mce log.

So, until we find a good use case, I don't ack this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
