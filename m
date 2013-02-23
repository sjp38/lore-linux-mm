Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 922ED6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 22:02:52 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id ta14so1159137obb.28
        for <linux-mm@kvack.org>; Fri, 22 Feb 2013 19:02:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5124AD8E.9040105@gmail.com>
References: <CAHGf_=rb0t4gbm0Egw9D3RUuwbgL8U6hPwBwS46C27mgAvJp0g@mail.gmail.com>
 <20130218145018.GJ4365@suse.de> <5124AD8E.9040105@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 22 Feb 2013 22:02:31 -0500
Message-ID: <CAHGf_=rnOhdkx+LgHAqf0xg925+BVPwasgMvFuzpobwa4ed9+Q@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC][ATTEND] a few topics I'd like to discuss
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Feb 20, 2013 at 6:03 AM, Simon Jeons <simon.jeons@gmail.com> wrote:
> On 02/18/2013 10:50 PM, Mel Gorman wrote:
>>
>> On Sun, Feb 17, 2013 at 01:44:33AM -0500, KOSAKI Motohiro wrote:
>>>
>>> Sorry for the delay.
>>>
>>> I would like to discuss the following topics:
>>>
>>>
>>>
>>> * Hugepage migration ? Currently, hugepage is not migratable and can?t
>>> use pages in ZONE_MOVABLE.  It is not happy from point of CMA/hotplug
>>> view.
>>>
>> migrate_huge_page() ?
>
>
> It seems that migrate_huge_page just called in memory failure path, why
> can't support in memory hotplug path?

No big reason.
Now, horiguchi-san is developing this feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
