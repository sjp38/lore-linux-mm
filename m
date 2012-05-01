Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 89E786B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 14:06:00 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so3183297lbj.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 11:05:58 -0700 (PDT)
Message-ID: <4FA02603.80807@openvz.org>
Date: Tue, 01 May 2012 22:05:55 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 3/3] proc/smaps: show amount of hwpoison pages
References: <20120430112903.14137.81692.stgit@zurg> <20120430112910.14137.28935.stgit@zurg> <CAHGf_=rWDMMv2dKz3paV2MnjsCNWBa2BaUTi+RnDo8DZ4zEr=g@mail.gmail.com>
In-Reply-To: <CAHGf_=rWDMMv2dKz3paV2MnjsCNWBa2BaUTi+RnDo8DZ4zEr=g@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

KOSAKI Motohiro wrote:
> On Mon, Apr 30, 2012 at 7:29 AM, Konstantin Khlebnikov
> <khlebnikov@openvz.org>  wrote:
>> This patch adds line "HWPoinson:<size>  kB" into /proc/pid/smaps if
>> CONFIG_MEMORY_FAILURE=y and some HWPoison pages were found.
>> This may be useful for searching applications which use a broken memory.
>
> I dislike "maybe useful" claim. If we don't know exact motivation of a feature,
> we can't maintain them especially when a bugfix can't avoid ABI change.
>
> Please write down exact use case.

I don't know how to exactly use this hw-poison stuff, but smaps suppose to
export state of ptes in vma. It seems to rational to show also hw-poisoned ptes,
since kernel has this feature and pte can be in hw-poisoned state.

and now everyone can easily find them:
# sudo grep HWPoison /proc/*/smaps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
