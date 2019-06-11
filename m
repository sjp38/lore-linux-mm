Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A444C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:46:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C69B520896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:46:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="hLRASOXJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C69B520896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 598A36B000C; Tue, 11 Jun 2019 08:46:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 549846B0010; Tue, 11 Jun 2019 08:46:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45EE26B0266; Tue, 11 Jun 2019 08:46:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26E596B000C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:46:50 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g30so11677529qtm.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:46:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=ZpJoiyTHXYiF7kVWlp5BjDY7BKtjLiYkm/X37H4JtRA=;
        b=myiOPLEs4dQtW/9SkQ8rvPn2QWwpIbXShyHdl7nxyBqTtS/Ny6lI1jqZi8jUgu1cQR
         /580tDFyX6fIbPek7oCauPWZGYGoowc/IJzX4qWOZ7i++0Bo60yZMCcwB1KNKQOSVesc
         zbVI14Na41ewvkYxwM55aIlImwG3afZK560SB7wVxtlfTCM2RhKhPtFw1TUwzl/ah67Q
         UxkCKNKwQZyF37XJwCdYsLOoWvn3MfE897vk16ilHizPF9z9URxY5gCP576SjjpWLTHb
         rf5YcjAcYtZuW0Qf1IISxsFdqR8e4HnJCe7Myji4vHfKX5QFw8HYWoVkbo3lcg7iBPwf
         O85w==
X-Gm-Message-State: APjAAAXmjcCr1XCqDGg6zML8dbG8Zv2gxwHgsl7lnKPx3U1NQ6vHCvM+
	/kOpIklo31bP+B4YO1S392eHacaHcM4tzE3/0i8PwvcpA+BwkbcPUIeS4QdtaXVbGeqdYKECVT/
	MlzmC3LejB1SNgM/QJwuOPdbNPjia8fSwmWzt9gtGBxMzg7t6Km5Omw5raE7CVKO/SA==
X-Received: by 2002:ac8:3faa:: with SMTP id d39mr64468851qtk.240.1560257209816;
        Tue, 11 Jun 2019 05:46:49 -0700 (PDT)
X-Received: by 2002:ac8:3faa:: with SMTP id d39mr64468729qtk.240.1560257208168;
        Tue, 11 Jun 2019 05:46:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560257208; cv=none;
        d=google.com; s=arc-20160816;
        b=FYpkq6Tw2BE/Vjdok6sUYNyYqgHj2ItuAoDDhrK1JUNqq5C8qzcmqOhcLcILJjMftd
         20+sgerPyfrE9FqpTgWG/fD6NU4osPEVpggqyE+v22MXKyRWZbCh6ImgNW/kbZr2udhZ
         0P4DSFc89vuPZILHPhXvdB9wc76GzD0OZPSWI9EzT12nLfCYfdHZXW0mf7Y9WDN+smtM
         uOwX0NTeD6krlSSc7++sJvrtSnGR3ionPpgz/8sETfTzjluv/Nnpr1q2DDiEFBCD6lu5
         aZEYZvb0eWdikATTxvNzdQB29djpYZZrYjF5T7xK0sPd3bo5g+xy161ARQYGyEnJBd+l
         a0HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=ZpJoiyTHXYiF7kVWlp5BjDY7BKtjLiYkm/X37H4JtRA=;
        b=NqscGxicLr2MLywEAvgDbcNplCE3UpZlT6o+/QhpBu/u+d8ZRw3tHuj/jgRk3c3PzO
         MA5LmY25F+tjVjyAT08zl166uG7FzCQPs2Wto3XFo9o4xxdTEobfcqHHgMtPoj+1zJb7
         JGypmbggK45zGCH2y6Y+lgVgONzmeCeJdZeoUmTVa//qJrFAHkkCohSKHn7EpINcxj7O
         kXEui4qAUhPFE0wm1S67VQNrj8YuPqZWiMcTdb2pdELEICwHmMJQMD0HIy0/SH6GABrf
         gIPPJ3v3xvcfWC8M3WruiqgTBsaeLvMLII3m//UgGqaennuph9wKhW1P/F67ZoyDL4eN
         7L7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=hLRASOXJ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u44sor2895546qvh.40.2019.06.11.05.46.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 05:46:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=hLRASOXJ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=ZpJoiyTHXYiF7kVWlp5BjDY7BKtjLiYkm/X37H4JtRA=;
        b=hLRASOXJ6YWopQW2zJe/it1PtEXmPcjruiqSpyOQKa5oD3C8YF+KvSNFv+xPBPv8TH
         CzCRYOnzTi4MviZsxUxLvtnYX/SstM6qMHkP2ZjCGdKb4NOMo4OzomCUwM9AkZRJvLcY
         zBlSTNXp47ZYVck/lb2Vf8hj+ivWJlgzX8hHHfJACZXIAazfHU6t6bVEp/2MWe1uv3gW
         uyDUU1Pw4fo18A5CmdAe1aQn+1GjjYUMlwnvuYNfoWxQ+TfCNSVL8tW0FDAe57IqSIZl
         TCwTH4gLQ/iBsYni03TKMCwq5TPb+YwXTrsEGY4TugtM+wRkRbwhzTzCkT+wKtQlm0Df
         hqZQ==
X-Google-Smtp-Source: APXvYqwO5+sxJPYjLg249ECV9oOGg9Mp8tZmJ0f1umM1BO5C8rtfLDuiPkC+udH3Ifno3lmofhD1OA==
X-Received: by 2002:a0c:95af:: with SMTP id s44mr33429845qvs.162.1560257207741;
        Tue, 11 Jun 2019 05:46:47 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s23sm6636182qtk.31.2019.06.11.05.46.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:46:46 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
From: Qian Cai <cai@lca.pw>
In-Reply-To: <20190611124118.GA4761@rapoport-lnx>
Date: Tue, 11 Jun 2019 08:46:45 -0400
Cc: Mark Rutland <mark.rutland@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 catalin.marinas@arm.com,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 mhocko@kernel.org,
 linux-mm@kvack.org,
 vdavydov.dev@gmail.com,
 hannes@cmpxchg.org,
 cgroups@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <3F6E1B9F-3789-4648-B95C-C4243B57DA02@lca.pw>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190610114326.GF15979@fuggles.cambridge.arm.com>
 <1560187575.6132.70.camel@lca.pw>
 <20190611100348.GB26409@lakrids.cambridge.arm.com>
 <20190611124118.GA4761@rapoport-lnx>
To: Mike Rapoport <rppt@linux.ibm.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 11, 2019, at 8:41 AM, Mike Rapoport <rppt@linux.ibm.com> wrote:
>=20
> On Tue, Jun 11, 2019 at 11:03:49AM +0100, Mark Rutland wrote:
>> On Mon, Jun 10, 2019 at 01:26:15PM -0400, Qian Cai wrote:
>>> On Mon, 2019-06-10 at 12:43 +0100, Will Deacon wrote:
>>>> On Tue, Jun 04, 2019 at 03:23:38PM +0100, Mark Rutland wrote:
>>>>> On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
>>>>>> The commit "arm64: switch to generic version of pte allocation"
>>>>>> introduced endless failures during boot like,
>>>>>>=20
>>>>>> kobject_add_internal failed for pgd_cache(285:chronyd.service) =
(error:
>>>>>> -2 parent: cgroup)
>>>>>>=20
>>>>>> It turns out __GFP_ACCOUNT is passed to kernel page table =
allocations
>>>>>> and then later memcg finds out those don't belong to any cgroup.
>>>>>=20
>>>>> Mike, I understood from [1] that this wasn't expected to be a =
problem,
>>>>> as the accounting should bypass kernel threads.
>>>>>=20
>>>>> Was that assumption wrong, or is something different happening =
here?
>>>>>=20
>>>>>>=20
>>>>>> backtrace:
>>>>>>   kobject_add_internal
>>>>>>   kobject_init_and_add
>>>>>>   sysfs_slab_add+0x1a8
>>>>>>   __kmem_cache_create
>>>>>>   create_cache
>>>>>>   memcg_create_kmem_cache
>>>>>>   memcg_kmem_cache_create_func
>>>>>>   process_one_work
>>>>>>   worker_thread
>>>>>>   kthread
>>>>>>=20
>>>>>> Signed-off-by: Qian Cai <cai@lca.pw>
>>>>>> ---
>>>>>>  arch/arm64/mm/pgd.c | 2 +-
>>>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>>=20
>>>>>> diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
>>>>>> index 769516cb6677..53c48f5c8765 100644
>>>>>> --- a/arch/arm64/mm/pgd.c
>>>>>> +++ b/arch/arm64/mm/pgd.c
>>>>>> @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
>>>>>>  	if (PGD_SIZE =3D=3D PAGE_SIZE)
>>>>>>  		return (pgd_t *)__get_free_page(gfp);
>>>>>>  	else
>>>>>> -		return kmem_cache_alloc(pgd_cache, gfp);
>>>>>> +		return kmem_cache_alloc(pgd_cache, =
GFP_PGTABLE_KERNEL);
>>>>>=20
>>>>> This is used to allocate PGDs for both user and kernel pagetables =
(e.g.
>>>>> for the efi runtime services), so while this may fix the =
regression, I'm
>>>>> not sure it's the right fix.
>>>>>=20
>>>>> Do we need a separate pgd_alloc_kernel()?
>>>>=20
>>>> So can I take the above for -rc5, or is somebody else working on a =
different
>>>> fix to implement pgd_alloc_kernel()?
>>>=20
>>> The offensive commit "arm64: switch to generic version of pte =
allocation" is not
>>> yet in the mainline, but only in the Andrew's tree and linux-next, =
and I doubt
>>> Andrew will push this out any time sooner given it is broken.
>>=20
>> I'd assumed that Mike would respin these patches to implement and use
>> pgd_alloc_kernel() (or take gfp flags) and the updated patches would
>> replace these in akpm's tree.
>>=20
>> Mike, could you confirm what your plan is? I'm happy to review/test
>> updated patches for arm64.
>=20
> Sorry for the delay, I'm mostly offline these days.
>=20
> I wanted to understand first what is the reason for the failure. I've =
tried
> to reproduce it with qemu, but I failed to find a bootable =
configuration
> that will have PGD_SIZE !=3D PAGE_SIZE :(
>=20
> Qian Cai, can you share what is your environment and the kernel =
config?


https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config

# lscpu
Architecture:        aarch64
Byte Order:          Little Endian
CPU(s):              256
On-line CPU(s) list: 0-255
Thread(s) per core:  4
Core(s) per socket:  32
Socket(s):           2
NUMA node(s):        2
Vendor ID:           Cavium
Model:               1
Model name:          ThunderX2 99xx
Stepping:            0x1
BogoMIPS:            400.00
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            32768K
NUMA node0 CPU(s):   0-127
NUMA node1 CPU(s):   128-255
Flags:               fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics =
cpuid asimdrdm

# dmidecode
Handle 0x0001, DMI type 1, 27 bytes
System Information
        Manufacturer: HPE
        Product Name: Apollo 70            =20
        Version: X1
        Wake-up Type: Power Switch
        Family: CN99XX


