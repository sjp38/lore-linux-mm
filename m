Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0515C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:16:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A02C20656
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:16:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A02C20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D22BD6B02B5; Tue, 16 Apr 2019 11:16:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD2496B02B6; Tue, 16 Apr 2019 11:16:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC2C66B02B7; Tue, 16 Apr 2019 11:16:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D35E6B02B5
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:16:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k56so5300374edb.2
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:16:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=eZpaZXKsWEj4BbCRQbjjtTp+Nx1toosw/2jqTit5u5o=;
        b=mqW6fhLmxiZs/WslHiivXSWzqg8lAyHoRwbuuzgICqYI19gDWLdXDLn1FEhm/PofTb
         gWyYc89e0Ym6Kd8xy/tR0BHaa0ZBHo6wG524s4ZGWPRzRoH9Jbt1fFGRgibTdNlTeWwz
         1xdt2UmBBWH4TY64aR82Bdhc0o67LV9oEQ2HQIsnfORXngCEWjipVvz65ZlkV5uf7E/I
         wjxk1rtPS8rkZYqNyfNJBbnXCanJn/0oi56sUauzPVELxnZ+z1UB5ZgOuPKLPj4L0Ki5
         QuMBucRuuUOBihAXN50MQxpnsIJ5Pc6awiF8EfefBjSup+1QvFbKUczP52zDUzElgdTO
         yVDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWtQW1h6NUsKWcj2kdZuZo7SbSE8Psp1S4s1W4XRjMxU/2HfKut
	DumL8lCXd4jwXpxEHfSikltgEyvZwxS70dhRBwgsQHA9kq8Ju0FZHmE6lWZkzkZgZlCl+oM3HKA
	OrduBIPUvfmHpdSssTHaHJd0u4INVBr2GZklf6NOCuBlm7NkONJ9QoorOeJSRSsvhRA==
X-Received: by 2002:a17:906:6050:: with SMTP id p16mr43723314ejj.173.1555427767840;
        Tue, 16 Apr 2019 08:16:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyz/S26atmmVqHMOZGKOLN5kiWEHrhnjY++3oytVc7/R0UNrFTW9km4hVZaa03nSUqburzz
X-Received: by 2002:a17:906:6050:: with SMTP id p16mr43723257ejj.173.1555427766834;
        Tue, 16 Apr 2019 08:16:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555427766; cv=none;
        d=google.com; s=arc-20160816;
        b=Ot4XTW9cCXWisWRvzjOv1i7AOO2IcrGYMesFZHI2nn3ddwZR/GVPuQKn1Hh+Mntmod
         LzTbZ4dx5QkuBnZQX8jmPUggexSJzXOgD1EN8sbhfF1TSddbG1Y6jcwFT7FSeuW63nEG
         iqrXLeDrvKFRplWusoOBqgpAvZkoxyU3YYXtg8HsUC9/uUBMT5A/w1PXHpItYWLVI0J2
         KGsfsdA/1wsi3fGVb3Kz9u5B7m+4CtQ+aQ0dxY/g2g9pfM/puMEH2hauuAZJFKMsHxTL
         W62WJ9+EmGyyR5MmDwWvsCd9LGbHfcOjkev/xYBVYofAu7WRdkUTuuAzR38kfLxcbYGA
         o9BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=eZpaZXKsWEj4BbCRQbjjtTp+Nx1toosw/2jqTit5u5o=;
        b=A20RSj0fDlbxjCZ74kQsYvTFy/i1zYONZPNd8DUikPkQ3MtnEOo1UD9GhnuGvif11C
         qfLYOmcXWuPjmyjVQXhpRJwOatauwcyGYl2XZzL58PvFd9Ne6VL4zreJk6bOrtHcLmrY
         SsPV0N2Kru8iooKmFMbjAhiSZksdmS4VYzOxIOmcNbK3PE/T/7ki8X0RSy+E9OzMP9nC
         9u2s1HvJgkjnj/VY5W+qjxwBWkVLJe9wypkddcJg6tWfvSojwVlcJ39ZKqkNfwhhrpMP
         B586CiRua/imIOxU9pQaUakNt8aWyLRnaC5JYnDoQuLi+itHSl3VFHDrgrpnNsKLCkzW
         lj2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e13si2450062edq.50.2019.04.16.08.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 08:16:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 25F3BAD70;
	Tue, 16 Apr 2019 15:16:06 +0000 (UTC)
Subject: Re: [PATCH v3] mm/hotplug: treat CMA pages as unmovable
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: mhocko@suse.com, osalvador@suse.de, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190413002623.8967-1-cai@lca.pw>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 mQINBFZdmxYBEADsw/SiUSjB0dM+vSh95UkgcHjzEVBlby/Fg+g42O7LAEkCYXi/vvq31JTB
 KxRWDHX0R2tgpFDXHnzZcQywawu8eSq0LxzxFNYMvtB7sV1pxYwej2qx9B75qW2plBs+7+YB
 87tMFA+u+L4Z5xAzIimfLD5EKC56kJ1CsXlM8S/LHcmdD9Ctkn3trYDNnat0eoAcfPIP2OZ+
 9oe9IF/R28zmh0ifLXyJQQz5ofdj4bPf8ecEW0rhcqHfTD8k4yK0xxt3xW+6Exqp9n9bydiy
 tcSAw/TahjW6yrA+6JhSBv1v2tIm+itQc073zjSX8OFL51qQVzRFr7H2UQG33lw2QrvHRXqD
 Ot7ViKam7v0Ho9wEWiQOOZlHItOOXFphWb2yq3nzrKe45oWoSgkxKb97MVsQ+q2SYjJRBBH4
 8qKhphADYxkIP6yut/eaj9ImvRUZZRi0DTc8xfnvHGTjKbJzC2xpFcY0DQbZzuwsIZ8OPJCc
 LM4S7mT25NE5kUTG/TKQCk922vRdGVMoLA7dIQrgXnRXtyT61sg8PG4wcfOnuWf8577aXP1x
 6mzw3/jh3F+oSBHb/GcLC7mvWreJifUL2gEdssGfXhGWBo6zLS3qhgtwjay0Jl+kza1lo+Cv
 BB2T79D4WGdDuVa4eOrQ02TxqGN7G0Biz5ZLRSFzQSQwLn8fbwARAQABtCBWbGFzdGltaWwg
 QmFia2EgPHZiYWJrYUBzdXNlLmN6PokCVAQTAQoAPgIbAwULCQgHAwUVCgkICwUWAgMBAAIe
 AQIXgBYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJcbbyGBQkH8VTqAAoJECJPp+fMgqZkpGoP
 /1jhVihakxw1d67kFhPgjWrbzaeAYOJu7Oi79D8BL8Vr5dmNPygbpGpJaCHACWp+10KXj9yz
 fWABs01KMHnZsAIUytVsQv35DMMDzgwVmnoEIRBhisMYOQlH2bBn/dqBjtnhs7zTL4xtqEcF
 1hoUFEByMOey7gm79utTk09hQE/Zo2x0Ikk98sSIKBETDCl4mkRVRlxPFl4O/w8dSaE4eczH
 LrKezaFiZOv6S1MUKVKzHInonrCqCNbXAHIeZa3JcXCYj1wWAjOt9R3NqcWsBGjFbkgoKMGD
 usiGabetmQjXNlVzyOYdAdrbpVRNVnaL91sB2j8LRD74snKsV0Wzwt90YHxDQ5z3M75YoIdl
 byTKu3BUuqZxkQ/emEuxZ7aRJ1Zw7cKo/IVqjWaQ1SSBDbZ8FAUPpHJxLdGxPRN8Pfw8blKY
 8mvLJKoF6i9T6+EmlyzxqzOFhcc4X5ig5uQoOjTIq6zhLO+nqVZvUDd2Kz9LMOCYb516cwS/
 Enpi0TcZ5ZobtLqEaL4rupjcJG418HFQ1qxC95u5FfNki+YTmu6ZLXy+1/9BDsPuZBOKYpUm
 3HWSnCS8J5Ny4SSwfYPH/JrtberWTcCP/8BHmoSpS/3oL3RxrZRRVnPHFzQC6L1oKvIuyXYF
 rkybPXYbmNHN+jTD3X8nRqo+4Qhmu6SHi3VquQENBFsZNQwBCACuowprHNSHhPBKxaBX7qOv
 KAGCmAVhK0eleElKy0sCkFghTenu1sA9AV4okL84qZ9gzaEoVkgbIbDgRbKY2MGvgKxXm+kY
 n8tmCejKoeyVcn9Xs0K5aUZiDz4Ll9VPTiXdf8YcjDgeP6/l4kHb4uSW4Aa9ds0xgt0gP1Xb
 AMwBlK19YvTDZV5u3YVoGkZhspfQqLLtBKSt3FuxTCU7hxCInQd3FHGJT/IIrvm07oDO2Y8J
 DXWHGJ9cK49bBGmK9B4ajsbe5GxtSKFccu8BciNluF+BqbrIiM0upJq5Xqj4y+Xjrpwqm4/M
 ScBsV0Po7qdeqv0pEFIXKj7IgO/d4W2bABEBAAGJA3IEGAEKACYWIQSpQNQ0mSwujpkQPVAi
 T6fnzIKmZAUCWxk1DAIbAgUJA8JnAAFACRAiT6fnzIKmZMB0IAQZAQoAHRYhBKZ2GgCcqNxn
 k0Sx9r6Fd25170XjBQJbGTUMAAoJEL6Fd25170XjDBUH/2jQ7a8g+FC2qBYxU/aCAVAVY0NE
 YuABL4LJ5+iWwmqUh0V9+lU88Cv4/G8fWwU+hBykSXhZXNQ5QJxyR7KWGy7LiPi7Cvovu+1c
 9Z9HIDNd4u7bxGKMpn19U12ATUBHAlvphzluVvXsJ23ES/F1c59d7IrgOnxqIcXxr9dcaJ2K
 k9VP3TfrjP3g98OKtSsyH0xMu0MCeyewf1piXyukFRRMKIErfThhmNnLiDbaVy6biCLx408L
 Mo4cCvEvqGKgRwyckVyo3JuhqreFeIKBOE1iHvf3x4LU8cIHdjhDP9Wf6ws1XNqIvve7oV+w
 B56YWoalm1rq00yUbs2RoGcXmtX1JQ//aR/paSuLGLIb3ecPB88rvEXPsizrhYUzbe1TTkKc
 4a4XwW4wdc6pRPVFMdd5idQOKdeBk7NdCZXNzoieFntyPpAq+DveK01xcBoXQ2UktIFIsXey
 uSNdLd5m5lf7/3f0BtaY//f9grm363NUb9KBsTSnv6Vx7Co0DWaxgC3MFSUhxzBzkJNty+2d
 10jvtwOWzUN+74uXGRYSq5WefQWqqQNnx+IDb4h81NmpIY/X0PqZrapNockj3WHvpbeVFAJ0
 9MRzYP3x8e5OuEuJfkNnAbwRGkDy98nXW6fKeemREjr8DWfXLKFWroJzkbAVmeIL0pjXATxr
 +tj5JC0uvMrrXefUhXTo0SNoTsuO/OsAKOcVsV/RHHTwCDR2e3W8mOlA3QbYXsscgjghbuLh
 J3oTRrOQa8tUXWqcd5A0+QPo5aaMHIK0UAthZsry5EmCY3BrbXUJlt+23E93hXQvfcsmfi0N
 rNh81eknLLWRYvMOsrbIqEHdZBT4FHHiGjnck6EYx/8F5BAZSodRVEAgXyC8IQJ+UVa02QM5
 D2VL8zRXZ6+wARKjgSrW+duohn535rG/ypd0ctLoXS6dDrFokwTQ2xrJiLbHp9G+noNTHSan
 ExaRzyLbvmblh3AAznb68cWmM3WVkceWACUalsoTLKF1sGrrIBj5updkKkzbKOq5gcC5AQ0E
 Wxk1NQEIAJ9B+lKxYlnKL5IehF1XJfknqsjuiRzj5vnvVrtFcPlSFL12VVFVUC2tT0A1Iuo9
 NAoZXEeuoPf1dLDyHErrWnDyn3SmDgb83eK5YS/K363RLEMOQKWcawPJGGVTIRZgUSgGusKL
 NuZqE5TCqQls0x/OPljufs4gk7E1GQEgE6M90Xbp0w/r0HB49BqjUzwByut7H2wAdiNAbJWZ
 F5GNUS2/2IbgOhOychHdqYpWTqyLgRpf+atqkmpIJwFRVhQUfwztuybgJLGJ6vmh/LyNMRr8
 J++SqkpOFMwJA81kpjuGR7moSrUIGTbDGFfjxmskQV/W/c25Xc6KaCwXah3OJ40AEQEAAYkC
 PAQYAQoAJhYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJbGTU1AhsMBQkDwmcAAAoJECJPp+fM
 gqZkPN4P/Ra4NbETHRj5/fM1fjtngt4dKeX/6McUPDIRuc58B6FuCQxtk7sX3ELs+1+w3eSV
 rHI5cOFRSdgw/iKwwBix8D4Qq0cnympZ622KJL2wpTPRLlNaFLoe5PkoORAjVxLGplvQIlhg
 miljQ3R63ty3+MZfkSVsYITlVkYlHaSwP2t8g7yTVa+q8ZAx0NT9uGWc/1Sg8j/uoPGrctml
 hFNGBTYyPq6mGW9jqaQ8en3ZmmJyw3CHwxZ5FZQ5qc55xgshKiy8jEtxh+dgB9d8zE/S/UGI
 E99N/q+kEKSgSMQMJ/CYPHQJVTi4YHh1yq/qTkHRX+ortrF5VEeDJDv+SljNStIxUdroPD29
 2ijoaMFTAU+uBtE14UP5F+LWdmRdEGS1Ah1NwooL27uAFllTDQxDhg/+LJ/TqB8ZuidOIy1B
 xVKRSg3I2m+DUTVqBy7Lixo73hnW69kSjtqCeamY/NSu6LNP+b0wAOKhwz9hBEwEHLp05+mj
 5ZFJyfGsOiNUcMoO/17FO4EBxSDP3FDLllpuzlFD7SXkfJaMWYmXIlO0jLzdfwfcnDzBbPwO
 hBM8hvtsyq8lq8vJOxv6XD6xcTtj5Az8t2JjdUX6SF9hxJpwhBU0wrCoGDkWp4Bbv6jnF7zP
 Nzftr4l8RuJoywDIiJpdaNpSlXKpj/K6KrnyAI/joYc7
Message-ID: <7b00e0ab-4d57-843a-df08-5f5b2162f7bf@suse.cz>
Date: Tue, 16 Apr 2019 17:12:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190413002623.8967-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/13/19 2:26 AM, Qian Cai wrote:
> has_unmovable_pages() is used by allocating CMA and gigantic pages as
> well as the memory hotplug. The later doesn't know how to offline CMA
> pool properly now, but if an unused (free) CMA page is encountered, then
> has_unmovable_pages() happily considers it as a free memory and
> propagates this up the call chain. Memory offlining code then frees the
> page without a proper CMA tear down which leads to an accounting issues.
> Moreover if the same memory range is onlined again then the memory never
> gets back to the CMA pool.
> 
> State after memory offline:
>  # grep cma /proc/vmstat
>  nr_free_cma 205824
> 
>  # cat /sys/kernel/debug/cma/cma-kvm_cma/count
>  209920
> 
> Also, kmemleak still think those memory address are reserved but have
> already been used by the buddy allocator after onlining.
> 
> Offlined Pages 4096
> kmemleak: Cannot insert 0xc000201f7d040008 into the object search tree
> (overlaps existing)
> Call Trace:
> [c00000003dc2faf0] [c000000000884b2c] dump_stack+0xb0/0xf4 (unreliable)
> [c00000003dc2fb30] [c000000000424fb4] create_object+0x344/0x380
> [c00000003dc2fbf0] [c0000000003d178c] __kmalloc_node+0x3ec/0x860
> [c00000003dc2fc90] [c000000000319078] kvmalloc_node+0x58/0x110
> [c00000003dc2fcd0] [c000000000484d9c] seq_read+0x41c/0x620
> [c00000003dc2fd60] [c0000000004472bc] __vfs_read+0x3c/0x70
> [c00000003dc2fd80] [c0000000004473ac] vfs_read+0xbc/0x1a0
> [c00000003dc2fdd0] [c00000000044783c] ksys_read+0x7c/0x140
> [c00000003dc2fe20] [c00000000000b108] system_call+0x5c/0x70
> kmemleak: Kernel memory leak detector disabled
> kmemleak: Object 0xc000201cc8000000 (size 13757317120):
> kmemleak:   comm "swapper/0", pid 0, jiffies 4294937297
> kmemleak:   min_count = -1
> kmemleak:   count = 0
> kmemleak:   flags = 0x5
> kmemleak:   checksum = 0
> kmemleak:   backtrace:
>      cma_declare_contiguous+0x2a4/0x3b0
>      kvm_cma_reserve+0x11c/0x134
>      setup_arch+0x300/0x3f8
>      start_kernel+0x9c/0x6e8
>      start_here_common+0x1c/0x4b0
> kmemleak: Automatic memory scanning thread ended

There's nothing about what the patch does, except subject, which is long
forgotten when reading up to here. What about something like:

This patch fixes the situation by treating CMA pageblocks as unmovable,
except when has_unmovable_pages() is called as part of CMA allocation.

> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> @@ -8015,17 +8018,20 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	 * can still lead to having bootmem allocations in zone_movable.
>  	 */
>  
> -	/*
> -	 * CMA allocations (alloc_contig_range) really need to mark isolate
> -	 * CMA pageblocks even when they are not movable in fact so consider
> -	 * them movable here.
> -	 */
> -	if (is_migrate_cma(migratetype) &&
> -			is_migrate_cma(get_pageblock_migratetype(page)))
> -		return false;
> +	if (is_migrate_cma(get_pageblock_migratetype(page))) {

Nit, since you were already refactoring a bit as part of the patch:
this could use is_migrate_cma_page(page)

