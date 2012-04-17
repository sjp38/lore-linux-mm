Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C95FD6B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 14:07:10 -0400 (EDT)
Received: by dakh32 with SMTP id h32so9321382dak.9
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 11:07:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120417173203.GA32482@tiehlicka.suse.cz>
References: <20120417155502.GE22687@tiehlicka.suse.cz>
	<CAE9FiQXWKzv7Wo4iWGrKapmxQYtAGezghwup1UKoW2ghqUSr+A@mail.gmail.com>
	<20120417173203.GA32482@tiehlicka.suse.cz>
Date: Tue, 17 Apr 2012 11:07:10 -0700
Message-ID: <CAE9FiQXvZ4eSCwMSG2H7CC6suQe37TmQpmOEKW_082W3zz-6Fw@mail.gmail.com>
Subject: Re: Weirdness in __alloc_bootmem_node_high
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 17, 2012 at 10:32 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 17-04-12 10:12:30, Yinghai Lu wrote:
>>
>> We are not using bootmem with x86 now, so could remove those workaround now.
>
> Could you be more specific about what the workaround is used for?

Don't bootmem allocating too low to use up all low memory. like for
system with lots of memory for sparse vmemmap.

when nobootmem.c is used, __alloc_bootmem_node_high is the same as
__alloc_bootmem_node.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
