Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 4EC7C6B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 19:50:56 -0400 (EDT)
From: Alexey Ivanov <rbtz@yandex-team.ru>
In-Reply-To: <4F8326FD.8020507@redhat.com>
References: <37371333672160@webcorp7.yandex-team.ru> <4F7E9854.1020904@gmail.com> <12701333991475@webcorp7.yandex-team.ru> <4F8326FD.8020507@redhat.com>
Subject: Re: mapped pagecache pages vs unmapped pages
MIME-Version: 1.0
Message-Id: <8041334015453@webcorp4.yandex-team.ru>
Date: Tue, 10 Apr 2012 03:50:53 +0400
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=koi8-r
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "gnehzuil.lzheng@gmail.com" <gnehzuil.lzheng@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghan@google.com

Did you consider making this ratio tunable, at least manually(i.e. via sysctl)?
I suppose we are not the only ones with almost-whole-ram-mmaped workload.

09.04.2012, 22:56, "Rik van Riel" <riel@redhat.com>:
> On 04/09/2012 01:11 PM, Alexey Ivanov wrote:
>
>> ?Thanks for the hint!
>>
>> ?Can anyone clarify the reason of not using zone->inactive_ratio in inactive_file_is_low_global()?
>
> New anonymous pages start out on the active anon list, and
> are always referenced. ?If memory fills up, they may end
> up getting moved to the inactive anon list; being referenced
> while on the inactive anon list is enough to get them promoted
> back to the active list.
>
> New file pages start out on the INACTIVE file list, and
> start their lives not referenced at all. Due to readahead
> extra reads, many file pages may never be referenced.
>
> Only file pages that are referenced twice make it onto
> the active list.
>
> This means the inactive file list has to be large enough
> for all the readahead buffers, and give pages enough time
> on the list that frequently accessed ones can get accessed
> twice and promoted.
>
> http://linux-mm.org/PageReplacementDesign
>
> --
> All rights reversed

-- 
Alexey Ivanov
Yandex Search Admin Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
