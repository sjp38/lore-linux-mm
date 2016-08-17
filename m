Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 337DB6B025F
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:21:39 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id u13so233225286uau.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 02:21:39 -0700 (PDT)
Received: from mx04-000ceb01.pphosted.com (mx0b-000ceb01.pphosted.com. [67.231.152.126])
        by mx.google.com with ESMTPS id c3si29328131wjv.231.2016.08.17.02.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 02:21:37 -0700 (PDT)
Subject: Re: OOM killer changes
References: <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
 <20160816031222.GC16913@js1304-P5Q-DELUXE>
 <ef85bac4-cbaa-8def-bf76-11741301dc87@Quantum.com>
 <8db47fdf-2d6a-d234-479e-6cc81be98655@suse.cz>
 <CAAmzW4M0gmhn1Nub=kB-4gfxviCunmWYEMhj-uVfX+k5pVtmeA@mail.gmail.com>
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Message-ID: <d26d6f3a-e6be-4bf2-151f-f585aa5fdfb7@Quantum.com>
Date: Wed, 17 Aug 2016 02:21:30 -0700
MIME-Version: 1.0
In-Reply-To: <CAAmzW4M0gmhn1Nub=kB-4gfxviCunmWYEMhj-uVfX+k5pVtmeA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 17.08.2016 01:16, Joonsoo Kim wrote:
>
> Free scanner start at 0x27fe00 but actual scan happens at 0x186a00.
> And, although log is snipped, compaction fails because it doesn't find
> any freepage.
>
> It skips half of pageblocks in that zone. It would be due to
> migratetype or skipbit.
> Both Vlastimil's recent patches and my work-around should be applied to solve
> this problem.
>
> Other part of trace looks like that my work-around isn't applied.
> Could you confirm
> that?
>
> Thanks.
Your patch was in my last 4.7 run with the output in 
OOM_4.7.0_p3.tar.bz2 but not in _p2.

Ralf-Peter

----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
