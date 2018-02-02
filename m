Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66F1E6B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 04:33:01 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id y42so19086824qtc.19
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 01:33:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 12si1749380qtm.361.2018.02.02.01.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 01:33:00 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w129TJGn145477
	for <linux-mm@kvack.org>; Fri, 2 Feb 2018 04:32:59 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fvjtnxr3e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Feb 2018 04:32:59 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 2 Feb 2018 09:32:56 -0000
Subject: Re: [RFC] mm/migrate: Consolidate page allocation helper functions
References: <20180130050642.19834-1-khandual@linux.vnet.ibm.com>
 <20180130143635.GF21609@dhcp22.suse.cz>
 <53cf5454-405b-a812-1389-af4fd7527122@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1801302000200.8014@eggly.anvils>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 2 Feb 2018 15:02:49 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1801302000200.8014@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <2fe9bab9-d35d-e3fe-418a-41ab8f981ce8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 01/31/2018 09:56 AM, Hugh Dickins wrote:
> On Wed, 31 Jan 2018, Anshuman Khandual wrote:
>> On 01/30/2018 08:06 PM, Michal Hocko wrote:
>>> On Tue 30-01-18 10:36:42, Anshuman Khandual wrote:
>>>> Allocation helper functions for migrate_pages() remmain scattered with
>>>> similar names making them really confusing. Rename these functions based
>>>> on the context for the migration and move them all into common migration
>>>> header. Functionality remains unchanged.
> 
> I agree that their names could be made less confusing (though didn't
> succeed very well when I tried); and maybe a couple of them are general
> enough to be used from more than one callsite, and could well live in
> mm/migrate.c.
> 
> But moving all of page migration's (currently static) new_page allocator
> functions away from the code that relies on their special characteristics
> (probably relayed to them through a private argument), and into a single
> header file, just seems perverse to me.  And likely to be a nuisance when
> adding more in future: private structures having to be made public just
> to make them visible in that shared header file.
> 
> Would it make sense to keep the various functions that may be called by
> rmap_walk() together in one rmap_walk.h?  The different filesystems'
> writepage methods together in one writepage.h?  I don't think so.

Makes sense. Will probably just change the helper names to something
more meaningful (from previous suggestions in this thread) next around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
