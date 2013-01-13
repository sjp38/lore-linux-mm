Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 8C7856B0071
	for <linux-mm@kvack.org>; Sun, 13 Jan 2013 13:14:41 -0500 (EST)
Message-ID: <50F2F9CD.6080904@infradead.org>
Date: Sun, 13 Jan 2013 10:15:41 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] Fix wrong EOF compare
References: <1357871401-7075-1-git-send-email-minchan@kernel.org> <xa1tbocvby0s.fsf@mina86.com> <1358077473.32505.10@driftwood>
In-Reply-To: <1358077473.32505.10@driftwood>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Landley <rob@landley.net>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>

On 01/13/13 03:44, Rob Landley wrote:
> On 01/11/2013 08:21:55 AM, Michal Nazarewicz wrote:
>> On Fri, Jan 11 2013, Minchan Kim <minchan@kernel.org> wrote:
>> > The C standards allows the character type char to be singed or unsinged,
>> > depending on the platform and compiler. Most of systems uses signed char,
>> > but those based on PowerPC and ARM processors typically use unsigned char.
>> > This can lead to unexpected results when the variable is used to compare
>> > with EOF(-1). It happens my ARM system and this patch fixes it.
>> >
>> > Cc: Mel Gorman <mgorman@suse.de>
>> > Cc: Andy Whitcroft <apw@shadowen.org>
>> > Cc: Alexander Nyberg <alexn@dsv.su.se>
>> > Cc: Michal Nazarewicz <mina86@mina86.com>
>>
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>>
>> > Cc: Randy Dunlap <rdunlap@infradead.org>
>> > Signed-off-by: Minchan Kim <minchan@kernel.org>
>> > ---
>> >  Documentation/page_owner.c |    7 ++++---
>> >  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> My kernel tree doesn't have Documentation/page_owner.c, where do I find this file?

It's in -mm (mmotm), so Andrew can/should merge this ...


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
