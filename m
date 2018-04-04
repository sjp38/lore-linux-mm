Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DDE26B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 03:29:12 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id a207-v6so11401692itb.7
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 00:29:12 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j124si3265150ioe.23.2018.04.04.00.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 00:29:11 -0700 (PDT)
Subject: Re: [PATCH 2/2] kfree_rcu() should use kfree_bulk() interface
References: <1522647064-27167-1-git-send-email-rao.shoaib@oracle.com>
 <1522647064-27167-3-git-send-email-rao.shoaib@oracle.com>
 <alpine.DEB.2.20.1804021217070.24404@nuc-kabylake>
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <d6a58a0d-be8b-44e9-29c7-ef2588afefbf@oracle.com>
Date: Wed, 4 Apr 2018 00:28:53 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1804021217070.24404@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, joe@perches.com, willy@infradead.org, brouer@redhat.com, linux-mm@kvack.org



On 04/02/2018 10:20 AM, Christopher Lameter wrote:
> On Sun, 1 Apr 2018, rao.shoaib@oracle.com wrote:
>
>> kfree_rcu() should use the new kfree_bulk() interface for freeing
>> rcu structures as it is more efficient.
> It would be even better if this approach could also use
>
> 	kmem_cache_free_bulk()
>
> or
>
> 	kfree_bulk()
Sorry I do not understand your comment. The patch is using kfree_bulk() 
which is an inline function.

Shoaib
