Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF1B6B0354
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 09:19:58 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id u15so1213071qtu.11
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 06:19:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 39si836702qtm.361.2018.01.03.06.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 06:19:57 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w03EJIwB028944
	for <linux-mm@kvack.org>; Wed, 3 Jan 2018 09:19:56 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f8vah3xmc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Jan 2018 09:19:56 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 3 Jan 2018 14:19:54 -0000
Subject: Re: [PATCH 2/3] mm, migrate: remove reason argument from new_page_t
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-3-mhocko@kernel.org>
 <f31b8830-db49-05a2-9a64-d27476fd206c@linux.vnet.ibm.com>
 <20180103140923.GD11319@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 3 Jan 2018 19:49:40 +0530
MIME-Version: 1.0
In-Reply-To: <20180103140923.GD11319@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <2dff7c5e-118b-1e57-ef13-2fa7389895fd@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/03/2018 07:39 PM, Michal Hocko wrote:
> On Wed 03-01-18 19:30:38, Anshuman Khandual wrote:
>> On 01/03/2018 01:55 PM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> No allocation callback is using this argument anymore. new_page_node
>>> used to use this parameter to convey node_id resp. migration error
>>> up to move_pages code (do_move_page_to_node_array). The error status
>>> never made it into the final status field and we have a better way
>>> to communicate node id to the status field now. All other allocation
>>> callbacks simply ignored the argument so we can drop it finally.
>>
>> There is a migrate_pages() call in powerpc which needs to be changed
>> as well. It was failing the build on powerpc.
> 
> Yes, see http://lkml.kernel.org/r/20180103091134.GB11319@dhcp22.suse.cz

Oops, my bad. I am sorry, missed this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
