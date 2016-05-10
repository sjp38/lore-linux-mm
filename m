Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4B86B0005
	for <linux-mm@kvack.org>; Tue, 10 May 2016 16:39:52 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id aq1so42983259obc.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 13:39:52 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id e13si5404397igz.25.2016.05.10.13.39.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 13:39:51 -0700 (PDT)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 10 May 2016 14:39:50 -0600
Date: Tue, 10 May 2016 15:39:43 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] memory-hotplug: more general validation of zone
 during online
Message-ID: <20160510203943.GA22115@arbab-laptop.austin.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1462816419-4479-3-git-send-email-arbab@linux.vnet.ibm.com>
 <573223b8.c52b8d0a.9a3c0.6217@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <573223b8.c52b8d0a.9a3c0.6217@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Tue, May 10, 2016 at 11:08:56AM -0700, Yasuaki Ishimatsu wrote:
>On Mon,  9 May 2016 12:53:38 -0500
>Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
>> * If X is lower than Y, the onlined memory must lie at the end of X.
>> * If X is higher than Y, the onlined memory must lie at the start of X.
>
>If memory address has hole, memory address gets uncotinuous. Then memory
>cannot be changed the zone by above the two conditions. So the conditions
>shouold be removed.

I don't understand what you mean by this. Could you give an example?

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
