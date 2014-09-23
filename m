Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B5A406B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:36:41 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id em10so5783814wid.11
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:36:41 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id dz13si16762045wjb.100.2014.09.23.14.36.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 14:36:40 -0700 (PDT)
Message-ID: <5421E7E1.80203@infradead.org>
Date: Tue, 23 Sep 2014 14:36:33 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: mmotm 2014-09-22-16-57 uploaded
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org> <20140923190222.GA4662@roeck-us.net> <5421D8B1.1030504@infradead.org> <20140923205707.GA14428@roeck-us.net>
In-Reply-To: <20140923205707.GA14428@roeck-us.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, David Miller <davem@davemloft.net>

On 09/23/14 13:57, Guenter Roeck wrote:
> On Tue, Sep 23, 2014 at 01:31:45PM -0700, Randy Dunlap wrote:
>> On 09/23/14 12:02, Guenter Roeck wrote:
>>> On Mon, Sep 22, 2014 at 05:02:56PM -0700, akpm@linux-foundation.org wrote:
>>>> The mm-of-the-moment snapshot 2014-09-22-16-57 has been uploaded to
>>>>
>>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>>
>>>> mmotm-readme.txt says
>>>>
>>>> README for mm-of-the-moment:
>>>>
>>>> http://www.ozlabs.org/~akpm/mmotm/
>>>>
>>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>>>> more than once a week.
>>>>
>>> Sine I started testing this branch, I figure I might as well share the results.
>>>
>>> i386:allyesconfig
>>>
>>> drivers/built-in.o: In function `_scsih_qcmd':
>>> mpt2sas_scsih.c:(.text+0xf5327d): undefined reference to `__udivdi3'
>>> mpt2sas_scsih.c:(.text+0xf532b0): undefined reference to `__umoddi3'
>>>
>>> i386:allmodconfig
>>>
>>> ERROR: "__udivdi3" [drivers/scsi/mpt2sas/mpt2sas.ko] undefined!
>>> ERROR: "__umoddi3" [drivers/scsi/mpt2sas/mpt2sas.ko] undefined!
>>
>> A patch has been posted for that and I believe that Christoph Hellwig has
>> merged it.
>>
>>> mips:nlm_xlp_defconfig
>>>
>>> ERROR: "scsi_is_fc_rport" [drivers/scsi/libfc/libfc.ko] undefined!
>>> ERROR: "fc_get_event_number" [drivers/scsi/libfc/libfc.ko] undefined!
>>> ERROR: "skb_trim" [drivers/scsi/libfc/libfc.ko] undefined!
>>> ERROR: "fc_host_post_event" [drivers/scsi/libfc/libfc.ko] undefined!
>>>
>>> [and many more]
>>
>> I have posted a patch for these build errors.
>>
> mips:nlm_xlp_defconfig builds in next-20140923, but it doesn't configure
> CONFIG_NET. I don't see a patch which would address that problem.
> In case I am missing it, can you point me to your patch ?

I was referring to this one:
http://marc.info/?l=linux-scsi&m=141117068414761&w=2

although I think that Dave is also working on a patch that is a little
different from mine.

Neither of these patches enables CONFIG_NET.  They just add dependencies.

> On the other side, maybe it is just me thinking that taking CONFIG_NET out
> of standard configurations might be a problem. If so, apologies for the noise.



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
