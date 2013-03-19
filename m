Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 180A16B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:44:24 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id dr12so548940wgb.35
        for <linux-mm@kvack.org>; Tue, 19 Mar 2013 09:44:22 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <6041f181-67b1-4f71-bd5c-cfb48f1ddfb0@default>
References: <1363255697-19674-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<1363255697-19674-2-git-send-email-liwanp@linux.vnet.ibm.com>
	<20130316130302.GA5987@konrad-lan.dumpdata.com>
	<6041f181-67b1-4f71-bd5c-cfb48f1ddfb0@default>
Date: Tue, 19 Mar 2013 12:44:22 -0400
Message-ID: <CAPbh3rvOW2hh0bMTY_FyYJPiyqS4a76pHgDYLGYvLKjEzfJoig@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] introduce zero filled pages handler
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 16, 2013 at 2:24 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> From: Konrad Rzeszutek Wilk [mailto:konrad@darnok.org]
>> Subject: Re: [PATCH v2 1/4] introduce zero filled pages handler
>>
>> > +
>> > +   for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++) {
>> > +           if (page[pos])
>> > +                   return false;
>>
>> Perhaps allocate a static page filled with zeros and just do memcmp?
>
> That seems like a bad idea.  Why compare two different
> memory locations when comparing one memory location
> to a register will do?
>

Good point. I was hoping there was an fast memcmp that would
do fancy SSE registers. But it is memory against memory instead of
registers.

Perhaps a cunning trick would be to check (as a shortcircuit)
check against 'empty_zero_page' and if that check fails, then try
to do the check for each byte in the code?

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
