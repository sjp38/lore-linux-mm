Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 9B2176B005C
	for <linux-mm@kvack.org>; Sun,  3 Jun 2012 21:47:29 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2466429qcs.14
        for <linux-mm@kvack.org>; Sun, 03 Jun 2012 18:47:28 -0700 (PDT)
Message-ID: <4FCC13AC.3070005@gmail.com>
Date: Sun, 03 Jun 2012 21:47:24 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com> <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils> <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com> <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com> <alpine.LSU.2.00.1206012108430.11308@eggly.anvils> <4FCC0B09.1070708@kernel.org> <alpine.LSU.2.00.1206031820520.5143@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1206031820520.5143@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@gmail.com

>> -       set_pageblock_migratetype(page, MIGRATE_MOVABLE);
>> -       move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
>> +       set_pageblock_migratetype(start_page, MIGRATE_MOVABLE);
>> +       move_freepages_block(page_zone(start_page), start_page, MIGRATE_MOVABLE);
>
> No.  I guess we can assume the incoming page was valid (fair?),
> so should still use that, but something else for the loop iterator.

Fair. passed page is always valid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
