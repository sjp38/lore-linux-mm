Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 683926B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 13:53:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y29so99773pff.6
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 10:53:34 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id r12si4039108pgf.738.2017.09.14.10.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 10:53:33 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: slab: output reclaimable flag in /proc/slabinfo
References: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com>
 <1505409289-57031-2-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.20.1709141227010.529@nuc-kabylake>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <baa5a2e5-9a20-3baa-2156-3d00c2445541@alibaba-inc.com>
Date: Fri, 15 Sep 2017 01:53:13 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1709141227010.529@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/14/17 10:27 AM, Christopher Lameter wrote:
> Well /proc/slabinfo is a legacy interface. The infomation if a slab is
> reclaimable is available via the slabinfo tool. We would break a format
> that is relied upon by numerous tools.

Thanks for pointing this out. It would be unacceptable if it would break 
the backward compatibility.

A follow-up question is do we know what tools rely on the slabinfo format?

 From my point of view, although /proc/slabinfo is legacy, it sounds it 
is still used very often by the users.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
