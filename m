Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F62D6B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 12:23:44 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n137so9426059iod.18
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 09:23:44 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a134si6002201ioe.41.2017.11.03.09.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 09:23:43 -0700 (PDT)
Subject: Re: [PATCH 3/6] hugetlb: expose hugetlbfs_inode_info in header
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-4-marcandre.lureau@redhat.com>
 <30bfff65-4cb9-a6b6-ab31-73d767a4b8ae@oracle.com>
 <1675520780.35881890.1509725683143.JavaMail.zimbra@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3551915a-93bb-35ef-0062-e462357c9098@oracle.com>
Date: Fri, 3 Nov 2017 09:23:35 -0700
MIME-Version: 1.0
In-Reply-To: <1675520780.35881890.1509725683143.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 11/03/2017 09:14 AM, Marc-AndrA(C) Lureau wrote:
> Hi
> 
> ----- Original Message -----
>> On 10/31/2017 11:40 AM, Marc-AndrA(C) Lureau wrote:
>>> The following patch is going to access hugetlbfs_inode_info field from
>>> mm/shmem.c.
>>
>> The code looks fine.  However, I would prefer something different for the
>> commit message.  Perhaps something like:
>>
>> hugetlbfs inode information will need to be accessed by code in mm/shmem.c
>> for file sealing operations.  Move inode information definition from .c
>> file to header for needed access.
> 
> Ok, Does the patch get your Reviewed-by tag with that change?
> 
> thanks
> 

Yes, you can add
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

with an updated commit message.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
