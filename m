Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B441E6B002C
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 04:51:04 -0500 (EST)
Message-ID: <4F290B9E.1090605@redhat.com>
Date: Wed, 01 Feb 2012 17:53:34 +0800
From: Dave Young <dyoung@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] move vm tools from Documentation/vm/ to tools/
References: <20120201063420.GA10204@darkstar.nay.redhat.com> <CAOJsxLGVS3bK=hiKJu4NwTv-Nf8TCSAEL4reSZoY4=44hPt8rA@mail.gmail.com> <4F28EC9D.7000907@redhat.com> <20120201083032.GA6774@localhost>
In-Reply-To: <20120201083032.GA6774@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On 02/01/2012 04:30 PM, Wu Fengguang wrote:

> On Wed, Feb 01, 2012 at 03:41:17PM +0800, Dave Young wrote:
>> On 02/01/2012 03:32 PM, Pekka Enberg wrote:
>>
>>> On Wed, Feb 1, 2012 at 8:34 AM, Dave Young <dyoung@redhat.com> wrote:
>>>> tools/ is the better place for vm tools which are used by many people.
>>>> Moving them to tools also make them open to more users instead of hide in
>>>> Documentation folder.
>>>
>>> For moving the code:
>>>
>>> Acked-by: Pekka Enberg <penberg@kernel.org>
> 
> I have no problem with the move -- actually I sent a similar patch
> long time ago to Andrew ;)


Good to know, then do you mind I add your signed-off line?

> 
> Will git-mv end up with a better commit?
> 
>>>> Also fixed several coding style problem.
>>>
>>> Can you please make that a separate patch?
>>
>>
>> Will do.
>>
>> BTW, I think tools/slub/slabinfo.c should be included in tools/vm/ as
>> well, will move it in v2 patch
> 
> CC Christoph. Maybe not a big deal since it's already under tools/.
> 
> Thanks,
> Fengguang
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
