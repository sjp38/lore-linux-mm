Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7616C6B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:39:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q2so2693563pgn.22
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 02:39:30 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id a11-v6si3660080plp.363.2018.03.15.02.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 02:39:29 -0700 (PDT)
Subject: Re: [PATCH 4/8] struct page: add field for vm_struct
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <20180313214554.28521-5-igor.stoppa@huawei.com>
 <20180313220040.GA15791@bombadil.infradead.org>
 <7b18521c-539b-2ba1-823e-e83be071c13f@gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <6924c919-dbfb-a9f6-748a-0bbfe8d876b1@huawei.com>
Date: Thu, 15 Mar 2018 11:38:36 +0200
MIME-Version: 1.0
In-Reply-To: <7b18521c-539b-2ba1-823e-e83be071c13f@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <why2jjj.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 14/03/18 19:43, J Freyensee wrote:
> On 3/13/18 3:00 PM, Matthew Wilcox wrote:

[...]

>>> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
>> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Igor, do you mind sticking these tags on the files that have spent some 
> time reviewing a revision of your patchset (like the Reviewed-by: tags I 
> provided last revision?)

Apologies, that was not intentional, I forgot it.
I will do it, although most of the files will now change so much that I
am not sure what will survive, beside this patch, in the form that you
reviewed.

I suppose the Review-by tag drops, if the patch changes.

--
igor
