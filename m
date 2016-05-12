Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49DE66B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 02:48:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so56385418wmw.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 23:48:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g184si14919831wmf.26.2016.05.11.23.48.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 May 2016 23:48:40 -0700 (PDT)
Subject: Re: [PATCH 3/6] mm/page_owner: copy last_migrate_reason in
 copy_page_owner()
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-4-git-send-email-iamjoonsoo.kim@lge.com>
 <5731FA88.2060701@suse.cz> <20160512025858.GC8215@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57342745.5080006@suse.cz>
Date: Thu, 12 May 2016 08:48:37 +0200
MIME-Version: 1.0
In-Reply-To: <20160512025858.GC8215@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/12/2016 04:58 AM, Joonsoo Kim wrote:
> On Tue, May 10, 2016 at 05:13:12PM +0200, Vlastimil Babka wrote:
>
> Hmm... if it is the case, other fields are also misleading. I think
> that we can tolerate this corner case and keeping function semantic as
> function name suggests is better practice.

Hmm, OK. Let's not complicate it by specially marking pages that are 
under migration for now.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
