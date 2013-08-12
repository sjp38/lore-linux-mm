Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 0F84E6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 08:25:06 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id up14so170740obb.25
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 05:25:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130812121908.GA3196@phenom.dumpdata.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
	<20130806135800.GC1048@kroah.com>
	<52010714.2090707@oracle.com>
	<20130812121908.GA3196@phenom.dumpdata.com>
Date: Mon, 12 Aug 2013 21:25:05 +0900
Message-ID: <CAH9JG2VhN5-D132d0L0s8z4wQshfCeP5=aVWQLCAz7SP8HHyNg@mail.gmail.com>
Subject: Re: [PATCH v2 0/4] zcache: a compressed file page cache
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Bob Liu <bob.liu@oracle.com>, Greg KH <gregkh@linuxfoundation.org>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, ngupta@vflare.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org

On Mon, Aug 12, 2013 at 9:19 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Tue, Aug 06, 2013 at 10:24:20PM +0800, Bob Liu wrote:
>> Hi Greg,
>>
>> On 08/06/2013 09:58 PM, Greg KH wrote:
>> > On Tue, Aug 06, 2013 at 07:36:13PM +0800, Bob Liu wrote:
>> >> Dan Magenheimer extended zcache supporting both file pages and anonymous pages.
>> >> It's located in drivers/staging/zcache now. But the current version of zcache is
>> >> too complicated to be merged into upstream.
>> >
>> > Really?  If this is so, I'll just go delete zcache now, I don't want to
>> > lug around dead code that will never be merged.
>> >
>>
>> Zcache in staging have a zbud allocation which is almost the same as
>> mm/zbud.c but with different API and have a frontswap backend like
>> mm/zswap.c.
>> So I'd prefer reuse mm/zbud.c and mm/zswap.c for a generic memory
>> compression solution.
>> Which means in that case, zcache in staging = mm/zswap.c + mm/zcache.c +
>> mm/zbud.c.
>>
>> But I'm not sure if there are any existing users of zcache in staging,
>> if not I can delete zcache from staging in my next version of this
>> mm/zcache.c series.
>
> I think the Samsung folks are using it (zcache).

I'm not sure, but, at least, my team doesn't use it at now.

Thank you,
Kyungmin Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
