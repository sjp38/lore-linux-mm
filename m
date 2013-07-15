Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id ACD206B0039
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 10:08:52 -0400 (EDT)
Message-ID: <51E40272.6000806@sgi.com>
Date: Mon, 15 Jul 2013 09:08:50 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
References: <1373594635-131067-1-git-send-email-holt@sgi.com> <1373594635-131067-5-git-send-email-holt@sgi.com> <CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com> <51E0DA05.4090107@zytor.com> <CAE9FiQWFdQC_YZ1S-oyJbaWzpDHW4i_XT6SnWuwsoWzcL8_NLA@mail.gmail.com>
In-Reply-To: <CAE9FiQWFdQC_YZ1S-oyJbaWzpDHW4i_XT6SnWuwsoWzcL8_NLA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On 07/13/2013 12:31 AM, Yinghai Lu wrote:
> On Fri, Jul 12, 2013 at 9:39 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>> On 07/12/2013 09:19 PM, Yinghai Lu wrote:
>>>>          PG_reserved,
>>>> +       PG_uninitialized2mib,   /* Is this the right spot? ntz - Yes - rmh */
>>>>          PG_private,             /* If pagecache, has fs-private data */
>> The comment here is WTF...
> ntz: Nate Zimmer?
> rmh: Robin Holt?

Yea that comment was supposed to be removed.
Sorry about that.

Nate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
