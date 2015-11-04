Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8409B82F69
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 15:12:44 -0500 (EST)
Received: by oiad129 with SMTP id d129so34755066oia.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 12:12:44 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s1si1466987oek.88.2015.11.04.12.12.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 12:12:43 -0800 (PST)
Subject: Re: [PATCH 5/5] mm, page_owner: dump page owner info from dump_page()
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
 <1446649261-27122-6-git-send-email-vbabka@suse.cz>
 <20151104194104.GB13303@node.shutemov.name>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <563A66B7.5090102@oracle.com>
Date: Wed, 4 Nov 2015 15:12:39 -0500
MIME-Version: 1.0
In-Reply-To: <20151104194104.GB13303@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On 11/04/2015 02:41 PM, Kirill A. Shutemov wrote:
>> +	dump_page_owner(page);
> I tend to put dump_page() into random places during debug. Dumping page
> owner for all dump_page() cases can be too verbose.
> 
> Can we introduce dump_page_verbose() which would do usual dump_page() plus
> dump_page_owner()?
> 

Is there any existing piece of code that would use dump_page() rather than
dump_page_verbose()?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
