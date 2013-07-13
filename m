Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 0B14E6B0031
	for <linux-mm@kvack.org>; Sat, 13 Jul 2013 01:31:16 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so22850766ied.0
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 22:31:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51E0DA05.4090107@zytor.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
	<1373594635-131067-5-git-send-email-holt@sgi.com>
	<CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com>
	<51E0DA05.4090107@zytor.com>
Date: Fri, 12 Jul 2013 22:31:16 -0700
Message-ID: <CAE9FiQWFdQC_YZ1S-oyJbaWzpDHW4i_XT6SnWuwsoWzcL8_NLA@mail.gmail.com>
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@kernel.org>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, Jul 12, 2013 at 9:39 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 07/12/2013 09:19 PM, Yinghai Lu wrote:
>>>         PG_reserved,
>>> +       PG_uninitialized2mib,   /* Is this the right spot? ntz - Yes - rmh */
>>>         PG_private,             /* If pagecache, has fs-private data */
>
> The comment here is WTF...

ntz: Nate Zimmer?
rmh: Robin Holt?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
