Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 43BB56B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 08:39:01 -0500 (EST)
Received: by werf1 with SMTP id f1so7402008wer.14
        for <linux-mm@kvack.org>; Tue, 27 Dec 2011 05:38:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111227133021.GI5344@tiehlicka.suse.cz>
References: <CAJd=RBCXTp0GrMGw+MBDdj0K15+L5v+O2t6EcDghFk34aNwt1g@mail.gmail.com>
	<20111227125945.GH5344@tiehlicka.suse.cz>
	<CAJd=RBA70k8pCoP26hoJua=h1DHgx7eLHU0qrukJRxwoaxB65Q@mail.gmail.com>
	<20111227133021.GI5344@tiehlicka.suse.cz>
Date: Tue, 27 Dec 2011 21:38:59 +0800
Message-ID: <CAJd=RBAAbghkCK1R3VbzHyLN5aW6QgE1y+yjGofHUCxZjdTwvg@mail.gmail.com>
Subject: Re: [PATCH] mm: hugetlb: add might_sleep() for gigantic page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Dec 27, 2011 at 9:30 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 27-12-11 21:21:18, Hillf Danton wrote:
>> On Tue, Dec 27, 2011 at 8:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
>> > On Fri 23-12-11 21:41:08, Hillf Danton wrote:
>> >> From: Hillf Danton <dhillf@gmail.com>
>> >> Subject: [PATCH] mm: hugetlb: add might_sleep() for gigantic page
>> >>
>> >> Like the case of huge page, might_sleep() is added for gigantic page, then
>> >> both are treated in same way.
>> >
>> > Why do we need to call might_sleep here? There is cond_resched in the
>> > loop...
>> >
>>
>> IIUC it is the reason to add... and the comment says
>
> cond_resched calls __might_sleep so there is no reason to call
> might_sleep outside the loop as well.
>
Yes, thanks. And remove it in the huge page case?

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
