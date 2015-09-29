Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 20CE96B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 04:08:34 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so204062336pac.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 01:08:33 -0700 (PDT)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id ku5si35511895pbc.25.2015.09.29.01.08.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 01:08:33 -0700 (PDT)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 9107020A36
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 04:08:30 -0400 (EDT)
Subject: Re: [PATCH 2/2] mm/slub: use get_order() instead of fls()
References: <1443488787-2232-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1443488787-2232-2-git-send-email-weiyang@linux.vnet.ibm.com>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <560A46FC.8050205@iki.fi>
Date: Tue, 29 Sep 2015 11:08:28 +0300
MIME-Version: 1.0
In-Reply-To: <1443488787-2232-2-git-send-email-weiyang@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com
Cc: linux-mm@kvack.org

On 09/29/2015 04:06 AM, Wei Yang wrote:
> get_order() is more easy to understand.
>
> This patch just replaces it.
>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
